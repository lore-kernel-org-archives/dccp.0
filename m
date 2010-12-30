From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Dec 2010 06:29:15 +0000
Subject: Re: Sequence Number Validation Bug Fixes 0/2
Message-Id: <20101230062915.GA5119@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="7JfCtLOvnd9MIVvH"
List-Id: <dccp.vger.kernel.org>
References: <1293392426.3801.234.camel@jero-laptop>
In-Reply-To: <1293392426.3801.234.camel@jero-laptop>
To: dccp@vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Samuel,

| This tool converts DCCP CCID 2 connections to TCP connections which can
| then be analyzed with Tcptrace (http://tcptrace.org). (I can provide a
| link to the tool if people are interested).
| 
Please do -- such a tool has been missing for a long time, and the idea to hook
it up with tcptrace is both original and efficient. Analysing Ack Vectors using
tcpdump/wireshark is very tedious, so anything that can help in debugging Ack
Vector traces is a great help.

| It turns out this behavior is due to a nasty bug in the dccp sequence
| number validation code (dccp_check_seqno in input.c). What happens is
| that the receiver legitimately stops incrementing it's ack number
| because packets from the sender are outside the valid Ack window (why
| this happens is another problem I'm still working on). DCCP should send
| a sync when this happens, but this sync needs to be rate-limited. If it
| isn't time to send a sync, the DCCP code currently returns 0 which
| indicates that the packet is good!! 
| 
Thanks a lot, you have found a real bug. I have edited your patch since
Evolution squeezed tabs into whitespaces, and added your Signed-off --
please check the attached result, as I would like to submit this soon.


With regard to not updating the Ack Number, I remember having seen something
related earlier. There is a relationship between the current sending rate, the
Ack Ratio, the cwnd, and the Sequence Window. The Ack window is advanced by the
GSS and depends on the local value of the Sequence Window. RFC 4340, 7.5.2
recommends 5 * max_packets_per_RTT as guideline for Sequence Window.

When I looked at this earlier I noted that the dynamic update of Ack Ratio,
cwnd, and Sequence Window (which are all inter-related, but are controlled
by different code paths) does not produce the expected interaction, therefore
Ack Ratio is currently always 1 and Sequence Window is also static and does
not change throughout the connection. 

It may be that both these shortcuts cause the behaviour you observed. The
Ack Ratio update is disabled in net/dccp/feat.c:dccp_hdlr_ack_ratio(), but
there is currently no code to predict (guess) what the sending rate will
be for the next 5 RTTs -- if such a heuristic is possible.

I am interested in suggestions to improve this.

| In examining this section of code, I also noticed that the the GSR is
| updated by any packet in the valid sequence number window. I believe
| this represents a minor bug, because it would allow the GSR to move
| backward as a result of an out of order packet that is still in the
| valid window. I am also sending a patch for that as a separate email.
|
Excellent catch, there is a second bug here. Apart from the clerical edits
(please consult Documentation/SubmittingPatches), there is a small
modification, sent in response to the other patch. Please check this also -
both are very useful bug fixes, I have already put them into the test tree at

    git://eden-feed.erg.abdn.ac.uk/dccp_exp	[subtree 'dccp']

    http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=adc0984a00912f2297f8272d3756a279900f6ba9
    http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=9eb39613b014cee24b0b8e390bd221df6737954c

Gerrit

--7JfCtLOvnd9MIVvH
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="seqno_validation-1.diff"

dccp: fix return value for sequence-invalid packets

Currently dccp_check_seqno returns 0 (indicating a valid packet) if the
acknowledgment number is out of bounds and the sync that RFC 4340 mandates at
this point is currently being rate-limited. This function should return -1,
indicating an invalid packet.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -260,7 +260,7 @@ static int dccp_check_seqno(struct sock 
 		 */
 		if (time_before(now, (dp->dccps_rate_last +
 				      sysctl_dccp_sync_ratelimit)))
-			return 0;
+			return -1;
 
 		DCCP_WARN("Step 6 failed for %s packet, "
 			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "

--7JfCtLOvnd9MIVvH--
