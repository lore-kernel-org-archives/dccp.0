From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Jun 2010 11:14:35 +0000
Subject: [PATCH 2/2] dccp: make implementation of Syn-RTT symmetric
Message-Id: <1277205275-5862-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch is thanks to Andre Noll who reported the issue and helped testing.

The Syn-RTT sampled during the initial handshake currently only works for
the client sending the DCCP-Request. TFRC penalizes the absence of an RTT
sample with a very slow initial speed (1 packet per second), which delays
slow-start significantly, resulting in sluggish performance.

This patch mirrors the "Syn RTT" principle by adding a timestamp also onto
the DCCP-Response, producing an RTT sample  when the (Data)Ack completing
the handshake arrives.

Also changed the documentation to 'TFRC' since Syn RTTs are also used by CCID-4.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c   |   13 +++++++++++--
 net/dccp/options.c |    6 +++++-
 2 files changed, 16 insertions(+), 3 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -430,7 +430,7 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		if (dccp_parse_options(sk, NULL, skb))
 			return 1;
 
-		/* Obtain usec RTT sample from SYN exchange (used by CCID 3) */
+		/* Obtain usec RTT sample from SYN exchange (used by TFRC). */
 		if (likely(dp->dccps_options_received.dccpor_timestamp_echo))
 			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * (tstamp -
 			    dp->dccps_options_received.dccpor_timestamp_echo));
@@ -535,6 +535,8 @@ static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
 						   const struct dccp_hdr *dh,
 						   const unsigned len)
 {
+	struct dccp_sock *dp = dccp_sk(sk);
+	u32 sample = dp->dccps_options_received.dccpor_timestamp_echo;
 	int queued = 0;
 
 	switch (dh->dccph_type) {
@@ -559,7 +561,14 @@ static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
 		if (sk->sk_state = DCCP_PARTOPEN)
 			inet_csk_clear_xmit_timer(sk, ICSK_TIME_DACK);
 
-		dccp_sk(sk)->dccps_osr = DCCP_SKB_CB(skb)->dccpd_seq;
+		/* Obtain usec RTT sample from SYN exchange (used by TFRC). */
+		if (likely(sample)) {
+			long delta = dccp_timestamp() - sample;
+
+			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * delta);
+		}
+
+		dp->dccps_osr = DCCP_SKB_CB(skb)->dccpd_seq;
 		dccp_set_state(sk, DCCP_OPEN);
 
 		if (dh->dccph_type = DCCP_PKT_DATAACK ||
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -529,7 +529,7 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 		if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST) {
 			/*
 			 * Obtain RTT sample from Request/Response exchange.
-			 * This is currently used in CCID 3 initialisation.
+			 * This is currently used for TFRC initialisation.
 			 */
 			if (dccp_insert_option_timestamp(skb))
 				return -1;
@@ -562,6 +562,10 @@ int dccp_insert_options_rsk(struct dccp_request_sock *dreq, struct sk_buff *skb)
 	if (dccp_feat_insert_opts(NULL, dreq, skb))
 		return -1;
 
+	/* Obtain RTT sample from Response/Ack exchange (used by TFRC). */
+	if (dccp_insert_option_timestamp(skb))
+		return -1;
+
 	if (dreq->dreq_timestamp_echo != 0 &&
 	    dccp_insert_option_timestamp_echo(NULL, dreq, skb))
 		return -1;
-- 
1.6.0.rc2

