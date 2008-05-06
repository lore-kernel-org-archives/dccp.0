From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 May 2008 07:38:03 +0000
Subject: [PATCH 2/4] [CCID-3]: Simplify tx_parse_options
Message-Id: <1210059485-691-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This simplifies and consolidates the TX option-parsing code:

 1. The Loss Intervals option is not currently used, so dead code related to
    this option is removed. I am aware of no plans to support the option, but
    if someone wants to implement it (e.g. for inter-op tests), it is better
    to start afresh than having to also update currently unused code.

 2. The Loss Event and Receive Rate options have a lot of code in common (both
    are 32 bit, both have same length etc.), so this is consolidated.

 3. The test against GSR is not necessary, because
    - on first loading CCID3, ccid_new() zeroes out all fields in the socket;
    - ccid3_hc_tx_packet_recv() treats 0 and ~0U equivalently, due to

	pinv = opt_recv->ccid3or_loss_event_rate;
	if (pinv = ~0U || pinv = 0)
		hctx->p = 0;

    - as a result, the sequence number field is removed from opt_recv.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   57 +++++++++++------------------------------------
 net/dccp/ccids/ccid3.h |    3 --
 2 files changed, 14 insertions(+), 46 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -60,9 +60,6 @@ enum ccid3_options {
 };
 
 struct ccid3_options_received {
-	u64 ccid3or_seqno:48,
-	    ccid3or_loss_intervals_idx:16;
-	u16 ccid3or_loss_intervals_len;
 	u32 ccid3or_loss_event_rate;
 	u32 ccid3or_receive_rate;
 };
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -478,60 +478,31 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 				     unsigned char len, u16 idx,
 				     unsigned char *value)
 {
-	int rc = 0;
-	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv = &hctx->options_received;
 	__be32 opt_val;
 
-	if (opt_recv->ccid3or_seqno != dp->dccps_gsr) {
-		opt_recv->ccid3or_seqno		     = dp->dccps_gsr;
-		opt_recv->ccid3or_loss_event_rate    = ~0;
-		opt_recv->ccid3or_loss_intervals_idx = 0;
-		opt_recv->ccid3or_loss_intervals_len = 0;
-		opt_recv->ccid3or_receive_rate	     = 0;
-	}
-
 	switch (option) {
+	case TFRC_OPT_RECEIVE_RATE:
 	case TFRC_OPT_LOSS_EVENT_RATE:
 		if (unlikely(len != 4)) {
-			DCCP_WARN("%s(%p), invalid len %d "
-				  "for TFRC_OPT_LOSS_EVENT_RATE\n",
-				  dccp_role(sk), sk, len);
-			rc = -EINVAL;
-		} else {
-			opt_val = get_unaligned((__be32 *)value);
-			opt_recv->ccid3or_loss_event_rate = ntohl(opt_val);
-			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
-				       dccp_role(sk), sk,
-				       opt_recv->ccid3or_loss_event_rate);
+			DCCP_WARN("%s(%p), invalid len %d for %u\n",
+				  dccp_role(sk), sk, len, option);
+			return -EINVAL;
 		}
-		break;
-	case TFRC_OPT_LOSS_INTERVALS:
-		opt_recv->ccid3or_loss_intervals_idx = idx;
-		opt_recv->ccid3or_loss_intervals_len = len;
-		ccid3_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
-			       dccp_role(sk), sk,
-			       opt_recv->ccid3or_loss_intervals_idx,
-			       opt_recv->ccid3or_loss_intervals_len);
-		break;
-	case TFRC_OPT_RECEIVE_RATE:
-		if (unlikely(len != 4)) {
-			DCCP_WARN("%s(%p), invalid len %d "
-				  "for TFRC_OPT_RECEIVE_RATE\n",
-				  dccp_role(sk), sk, len);
-			rc = -EINVAL;
-		} else {
-			opt_val = get_unaligned((__be32 *)value);
-			opt_recv->ccid3or_receive_rate = ntohl(opt_val);
+		opt_val = ntohl(get_unaligned((__be32 *)value));
+
+		if (option = TFRC_OPT_RECEIVE_RATE) {
+			opt_recv->ccid3or_receive_rate = opt_val;
 			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
-				       dccp_role(sk), sk,
-				       opt_recv->ccid3or_receive_rate);
+				       dccp_role(sk), sk, opt_val);
+		} else {
+			opt_recv->ccid3or_loss_event_rate = opt_val;
+			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
+				       dccp_role(sk), sk, opt_val);
 		}
-		break;
 	}
-
-	return rc;
+	return 0;
 }
 
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)


The University of Aberdeen is a charity registered in Scotland, No SC013683.

