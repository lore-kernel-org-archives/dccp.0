From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 07 Aug 2007 11:40:59 +0000
Subject: [PATCH 1/1][BUG-Fix]: Divide-by-zero bug when running CCID3 data in both directions
Message-Id: <200708071240.59167@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have found a bug which is related to challenging CCID3 with heavy data
traffic in both directions. I built some test clients for simple services
and found that

 cat /boot/vmlinuz* | ./Discard/discard_client serverHost      # that's several MBytes

works without problems, but

 ./Echo/echo_client  serverHost  < /etc/bash_completion > out_file

fails miserably and produces the bug fixed by this patch.

The patch is provided for those who have checked the tree out; the latest test tree 
has this bug fix already merged in.

The bug occurs when loading CCID3 with data traffic in both directions. It
was observed using a simple echo client/server application (a la RFC 862).

After spending one afternoon of bug-hunting, the cause does not seem to be in the
TFRC unit, but rather due to the fact that heavy data transfer: 

  I have been printing out the sender's idea of its RTT and got horribly large values
  for the `quarter_RTTs' variable (from the algorithm in RFC 4342, section 8.1) - 
  larger than 11 was frequent when the RTT was about 3 milliseconds, i.e. 
         4 * 11 * 3 = 132 milliseconds. 
  There were values as large as 1467 for `quarter_RTTs'. 

Furthermore, this condition only occurs when using a large datafile as input (example 
above). Otherwise the bug will not be triggered. The reason seems to be that both sides 
send largely only Data packets, which starves sending of Acks (no DataAcks were observed);
which would explain the grossly over-estimated RTTs. 

There are two reasons why I don't want to fix this:

 1. CCID3 is not really designed for heavy bidirectional traffic. I think it is 
    important to really understand how CCID3 works in /one/ direction, before 
    adding the second dimension of reverse-path data traffic. 
    I think that CCID3 is ready for deployment in typical streaming applications, 
    which only have a small degree of return traffic (RTCP receiver reports, e.g.). 
    Engineering a heavy-duty bidirectional variant of CCID3 seems to me beside the 
    point. And it is expensive/complicated - CCID3 would have to check if it is 
    loaded on both half-connections, then try to optimise traffic and feedback by 
    piggy-backing. That is really stuff for later. Let's have a few running CCID3
    (one-directional) applications first.

 2. The whole idea of receiver-RTT-sampling seems broken to me. Imagine a QoS 
    traffic shaper between the two CCID end hosts (e.g. a large Token Bucket or 
    Leaky Bucket Filter) with a large queue; the device throttles, temporarily 
    stores the packets; when conditions change, it releases a large number of 
    stored packets at virtually the same time: for all these, the receiver RTT 
    samples will be close to zero.

I have added this as a known bug on http://linux-net.osdl.org/index.php/TODO#DCCP
and will post a link to the library and clients shortly, so that people can test.

The provided patch turns the machine-freeze condition into a safe one: 
 * the return value of tfrc_rx_sample_rtt() is now zero when this condition
   occurs, ie. the caller will skip over the sample;
 * a detailed warning is printed (you will notice);
 * applications will continue to work as before, without interruption.

Even with the hiccups, "diff outfile /etc/bash_completion" now returns 0 as desired :)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>    
---
 net/dccp/ccids/lib/packet_history.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -373,10 +373,22 @@ u32 tfrc_rx_sample_rtt(struct tfrc_rx_hi
 	if (delta_v < 1 || delta_v > 4) {	/* unsuitable CCVal delta */
 
 		if (h->rtt_sample_prev = 2) {	/* previous candidate stored */
-			sample = ktime_us_delta(rtt_prev_s(h)->stamp,
-					     rtt_last_s(h)->stamp);
-			sample *= 4 / SUB16(rtt_prev_s(h)->ccval,
-					    rtt_last_s(h)->ccval);
+			sample = SUB16(rtt_prev_s(h)->ccval,
+				       rtt_last_s(h)->ccval);
+			if (sample)
+				sample = 4 / sample
+				       * ktime_us_delta(rtt_prev_s(h)->stamp,
+							rtt_last_s(h)->stamp);
+			else    /*
+				 * FIXME: This condition is in principle not
+				 * possible but occurs when CCID is used for
+				 * two-way data traffic. I have tried to trace
+				 * it, but the cause does not seem to be here.
+				 */
+				DCCP_BUG("please report to dccp@vger.kernel.org"
+					 " - prev = %u, last =  %u",
+					 rtt_prev_s(h)->ccval,
+					 rtt_last_s(h)->ccval);
 		} else if (delta_v < 1) {
 			h->rtt_sample_prev = 1;
 			goto keep_ref_for_next_time;
