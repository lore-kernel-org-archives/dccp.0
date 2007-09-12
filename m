From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Sep 2007 14:35:17 +0000
Subject: [PATCH 5/5]: Fix Request/Response RTT sampling
Message-Id: <200709121535.17746@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Fix Request/Response RTT sampling

This fixes a problem with the Request/Response RTT sampling:

The current timestamp is taken after the options are processed, which is
too late if there is anything in the option processing code which takes
more than a trivial amount of time.

One instance is feature negotiation - I found that a full run through all
the option negotiation can take up to 38 ms. (Whether this says something
about feature negotiation or its implementation is a separate issue.)

The real problem (and it was caused by me) is that one does not know
how much time is spent in processing the options - and since DCCP has
space for up to 1020 bytes of options, the situation can be even much worse.

Therefore and since the Linux implementation always sends the required Elapsed
Time option, the timestamp is taken when the function is called, not later.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>    
---
 net/dccp/input.c |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -329,6 +329,7 @@ static int dccp_rcv_request_sent_state_p
 	if (dh->dccph_type = DCCP_PKT_RESPONSE) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 		struct dccp_sock *dp = dccp_sk(sk);
+		long tstamp = dccp_timestamp();
 
 		/* Stop the REQUEST timer */
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
@@ -349,13 +350,10 @@ static int dccp_rcv_request_sent_state_p
 		if (dccp_parse_options(sk, skb))
 			goto out_invalid_packet;
 
-		/* Obtain RTT sample from SYN exchange (used by CCID 3) */
-		if (dp->dccps_options_received.dccpor_timestamp_echo) {
-			long d = dccp_timestamp();
-
-			d -= dp->dccps_options_received.dccpor_timestamp_echo;
-			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * d);
-		}
+		/* Obtain usec RTT sample from SYN exchange (used by CCID 3) */
+		if (likely(dp->dccps_options_received.dccpor_timestamp_echo))
+			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * (tstamp -
+			    dp->dccps_options_received.dccpor_timestamp_echo));
 
 		if (dccp_msk(sk)->dccpms_send_ack_vector &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
