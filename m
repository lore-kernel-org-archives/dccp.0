From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 06 Dec 2008 16:40:51 +0000
Subject: [PATCH 1/7] dccp: Integration of dynamic feature activation - part 1 (socket setup)
Message-Id: <1228581657-6724-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This first patch out of three replaces the hardcoded default settings with
initialisation code for the dynamic feature negotiation.

The patch also ensures that the client feature-negotiation queue is flushed
only when entering the OPEN state.

Since confirmed Change options are removed as soon as they are confirmed
(in the DCCP-Response), this ensures that Confirm options are retransmitted.

Note on retransmitting Confirm options:
---------------------------------------
Implementation experience showed that it is necessary to retransmit Confirm
options. Thanks to Leandro Melo de Sales who reported a bug in an earlier
revision of the patch set, resulting from not retransmitting these options.

As long as the client is in PARTOPEN, it needs to retransmit the Confirm
options for the Change options received on the DCCP-Response from the server.

Otherwise, if the packet containing the Confirm options gets dropped in the
network, the connection aborts due to undefined feature negotiation state.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/proto.c |   46 ++++++----------------------------------------
 1 files changed, 6 insertions(+), 40 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -67,6 +67,9 @@ void dccp_set_state(struct sock *sk, const int state)
 	case DCCP_OPEN:
 		if (oldstate != DCCP_OPEN)
 			DCCP_INC_STATS(DCCP_MIB_CURRESTAB);
+		/* Client retransmits all Confirm options until entering OPEN */
+		if (oldstate = DCCP_PARTOPEN)
+			dccp_feat_list_purge(&dccp_sk(sk)->dccps_featneg);
 		break;
 
 	case DCCP_CLOSED:
@@ -175,7 +178,6 @@ EXPORT_SYMBOL_GPL(dccp_state_name);
 int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	dccp_minisock_init(&dp->dccps_minisock);
@@ -194,45 +196,9 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	dccp_init_xmit_timers(sk);
 
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
-
+	/* control socket doesn't need feat nego */
+	if (likely(ctl_sock_initialized))
+		return dccp_feat_init(sk);
 	return 0;
 }
 
