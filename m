From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 06 Dec 2008 16:40:55 +0000
Subject: [PATCH 5/7] dccp: Remove obsolete parts of the old CCID interface
Message-Id: <1228581657-6724-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The TX/RX CCIDs of the minisock are now redundant: similar to the Ack Vector
case, their value equals initially that of the sysctl, but at the end of
feature negotiation may be something different.

The old interface removed by this patch thus has been replaced by the newer
interface to dynamically query the currently loaded CCIDs.

Also removed are the constructors for the TX CCID and the RX CCID, since the
switch "rx <-> non-rx" is done by the handler in minisocks.c (and the handler
is the only place in the code where CCIDs are loaded).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 Documentation/networking/dccp.txt |    5 +++--
 include/linux/dccp.h              |    3 ---
 net/dccp/ccid.c                   |   14 --------------
 net/dccp/ccid.h                   |    5 -----
 net/dccp/feat.c                   |   13 -------------
 net/dccp/minisocks.c              |    2 --
 6 files changed, 3 insertions(+), 39 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -140,10 +140,11 @@ send_ackvec = 1
 	Whether or not to send Ack Vector options (sec. 11.5).
 
 tx_ccid = 2
-	Default CCID for the sender-receiver half-connection.
+	Default CCID for the sender-receiver half-connection. Depending on the
+	choice of CCID, the Send Ack Vector feature is enabled automatically.
 
 rx_ccid = 2
-	Default CCID for the receiver-sender half-connection.
+	Default CCID for the receiver-sender half-connection; see tx_ccid.
 
 seq_window = 100
 	The initial sequence window (sec. 7.5.2).
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -111,11 +111,6 @@ extern int  ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
 extern struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx,
 			     gfp_t gfp);
 
-extern struct ccid *ccid_hc_rx_new(unsigned char id, struct sock *sk,
-				   gfp_t gfp);
-extern struct ccid *ccid_hc_tx_new(unsigned char id, struct sock *sk,
-				   gfp_t gfp);
-
 static inline int ccid_get_current_rx_ccid(struct dccp_sock *dp)
 {
 	struct ccid *ccid = dp->dccps_hc_rx_ccid;
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -253,20 +253,6 @@ out_module_put:
 
 EXPORT_SYMBOL_GPL(ccid_new);
 
-struct ccid *ccid_hc_rx_new(unsigned char id, struct sock *sk, gfp_t gfp)
-{
-	return ccid_new(id, sk, 1, gfp);
-}
-
-EXPORT_SYMBOL_GPL(ccid_hc_rx_new);
-
-struct ccid *ccid_hc_tx_new(unsigned char id,struct sock *sk,  gfp_t gfp)
-{
-	return ccid_new(id, sk, 0, gfp);
-}
-
-EXPORT_SYMBOL_GPL(ccid_hc_tx_new);
-
 static void ccid_delete(struct ccid *ccid, struct sock *sk, int rx)
 {
 	struct ccid_operations *ccid_ops;
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -370,7 +370,6 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
   * Will be used to pass the state from dccp_request_sock to dccp_sock.
   *
   * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
-  * @dccpms_ccid - Congestion Control Id (CCID) (section 10)
   * @dccpms_send_ack_vector - Send Ack Vector Feature (section 11.5)
   * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
   * @dccpms_pending - List of features being negotiated
@@ -378,8 +377,6 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
   */
 struct dccp_minisock {
 	__u64			dccpms_sequence_window;
-	__u8			dccpms_rx_ccid;
-	__u8			dccpms_tx_ccid;
 	__u8			dccpms_send_ack_vector;
 	__u8			dccpms_send_ndp_count;
 	struct list_head	dccpms_pending;
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1124,22 +1124,9 @@ int dccp_feat_init(struct sock *sk)
 	INIT_LIST_HEAD(&dmsk->dccpms_pending);	/* XXX no longer used */
 	INIT_LIST_HEAD(&dmsk->dccpms_conf);	/* XXX no longer used */
 
-	/* CCID L */
-	rc = __feat_register_sp(&dp->dccps_featneg, DCCPF_CCID, 1, 0,
-				&dmsk->dccpms_tx_ccid, 1);
-	if (rc)
-		goto out;
-
-	/* CCID R */
-	rc = __feat_register_sp(&dp->dccps_featneg, DCCPF_CCID, 0, 0,
-				&dmsk->dccpms_rx_ccid, 1);
-	if (rc)
-		goto out;
-
 	/* Ack ratio */
 	rc = __feat_register_nn(&dp->dccps_featneg, DCCPF_ACK_RATIO, 0,
 				dp->dccps_l_ack_ratio);
-out:
 	return rc;
 }
 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -45,8 +45,6 @@ EXPORT_SYMBOL_GPL(dccp_death_row);
 void dccp_minisock_init(struct dccp_minisock *dmsk)
 {
 	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
-	dmsk->dccpms_rx_ccid	     = sysctl_dccp_feat_rx_ccid;
-	dmsk->dccpms_tx_ccid	     = sysctl_dccp_feat_tx_ccid;
 	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
 	dmsk->dccpms_send_ndp_count  = sysctl_dccp_feat_send_ndp_count;
 }
