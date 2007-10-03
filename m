From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:31 +0000
Subject: [PATCH 2/14]: Integration of dynamic feature activation - part 1 (socket setup)
Message-Id: <200710031502.31587@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Integration of dynamic feature activation - part 1 (socket setup)

This first patch out of three replaces the hardcoded default settings with
initialisation code for the dynamic feature negotiation.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/proto.c |   43 ++++---------------------------------------
 1 file changed, 4 insertions(+), 39 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -172,50 +172,15 @@ EXPORT_SYMBOL_GPL(dccp_unhash);
 int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	dccp_minisock_init(&dp->dccps_minisock);
 
 	INIT_LIST_HEAD(&dp->dccps_featneg);
-	/*
-	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
-	 * the listening (master) sock get CCID control blocks, which is not
-	 * necessary, but for now, to not mess with the test userspace apps,
-	 * lets leave it here, later the real solution is to do this in a
-	 * setsockopt(CCIDs-I-want/accept). -acme
-	 */
-	if (likely(ctl_sock_initialized)) {
-		int rc = dccp_feat_init(sk);
-
-		if (rc)
-			return rc;
-
-		if (dmsk->dccpms_send_ack_vector) {
-			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
-			if (dp->dccps_hc_rx_ackvec = NULL)
-				return -ENOMEM;
-		}
-		dp->dccps_hc_rx_ccid = ccid_hc_rx_new(dmsk->dccpms_rx_ccid,
-						      sk, GFP_KERNEL);
-		dp->dccps_hc_tx_ccid = ccid_hc_tx_new(dmsk->dccpms_tx_ccid,
-						      sk, GFP_KERNEL);
-		if (unlikely(dp->dccps_hc_rx_ccid = NULL ||
-			     dp->dccps_hc_tx_ccid = NULL)) {
-			ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
-			ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
-			if (dmsk->dccpms_send_ack_vector) {
-				dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
-				dp->dccps_hc_rx_ackvec = NULL;
-			}
-			dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
-			return -ENOMEM;
-		}
-	} else {
-		/* control socket doesn't need feat nego */
-		INIT_LIST_HEAD(&dmsk->dccpms_pending);
-		INIT_LIST_HEAD(&dmsk->dccpms_conf);
-	}
+	/* control socket doesn't need feat nego */
+	if (likely(ctl_sock_initialized))
+		if (dccp_feat_init(sk))
+			return -EPROTO;
 
 	dccp_init_xmit_timers(sk);
 	icsk->icsk_rto		= DCCP_TIMEOUT_INIT;
