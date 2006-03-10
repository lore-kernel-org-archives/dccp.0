From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:18 +0000
Subject: [PATCH 9/9] [DCCP] feat: Pass dccp_minisock ptr where only the minisock is used
Message-Id: <11420257382226-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is in preparation for having a dccp_minisock embedded into
dccp_request_sock so that feature negotiation can be done prior to
creating the full blown dccp_sock.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/feat.c  |   30 ++++++++++++++----------------
 net/dccp/feat.h  |    7 ++++---
 net/dccp/proto.c |   11 ++++++-----
 3 files changed, 24 insertions(+), 24 deletions(-)

5ce3566336cdf2c351e178368364516f76c964ff
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index ea77a53..54236e1 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -19,10 +19,9 @@
 
 #define DCCP_FEAT_SP_NOAGREE (-123)
 
-int dccp_feat_change(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len,
-		     gfp_t gfp)
+int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
+		     u8 *val, u8 len, gfp_t gfp)
 {
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct dccp_opt_pend *opt;
 	
 	dccp_pr_debug("feat change type=%d feat=%d\n", type, feature);
@@ -307,9 +306,9 @@ static int dccp_feat_nn(struct sock *sk,
 	return 0;
 }
 
-static void dccp_feat_empty_confirm(struct sock *sk, u8 type, u8 feature)
+static void dccp_feat_empty_confirm(struct dccp_minisock *dmsk,
+				    u8 type, u8 feature)
 {
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 	/* XXX check if other confirms for that are queued and recycle slot */
 	struct dccp_opt_pend *opt = kzalloc(sizeof(*opt), GFP_ATOMIC);
 
@@ -388,7 +387,7 @@ int dccp_feat_change_recv(struct sock *s
 		 * mandatory
 		 */
 		if (rc != DCCP_FEAT_SP_NOAGREE)
-			dccp_feat_empty_confirm(sk, type, feature);
+			dccp_feat_empty_confirm(dccp_msk(sk), type, feature);
 	}
 
 	/* generate the confirm [if required] */
@@ -456,9 +455,8 @@ int dccp_feat_confirm_recv(struct sock *
 
 EXPORT_SYMBOL_GPL(dccp_feat_confirm_recv);
 
-void dccp_feat_clean(struct sock *sk)
+void dccp_feat_clean(struct dccp_minisock *dmsk)
 {
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct dccp_opt_pend *opt, *next;
 
 	list_for_each_entry_safe(opt, next, &dmsk->dccpms_pending,
@@ -537,49 +535,49 @@ out:
 	return rc;
 
 out_clean:
-	dccp_feat_clean(newsk);
+	dccp_feat_clean(newdmsk);
 	rc = -ENOMEM;
 	goto out;
 }
 
 EXPORT_SYMBOL_GPL(dccp_feat_clone);
 
-static int __dccp_feat_init(struct sock *sk, u8 type, u8 feat, u8 *val, u8 len)
+static int __dccp_feat_init(struct dccp_minisock *dmsk, u8 type, u8 feat,
+			    u8 *val, u8 len)
 {
 	int rc = -ENOMEM;
 	u8 *copy = kmalloc(len, GFP_KERNEL);
 
 	if (copy != NULL) {
 		memcpy(copy, val, len);
-		rc = dccp_feat_change(sk, type, feat, copy, len, GFP_KERNEL);
+		rc = dccp_feat_change(dmsk, type, feat, copy, len, GFP_KERNEL);
 		if (rc)
 			kfree(copy);
 	}
 	return rc;
 }
 
-int dccp_feat_init(struct sock *sk)
+int dccp_feat_init(struct dccp_minisock *dmsk)
 {
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 	int rc;
 
 	INIT_LIST_HEAD(&dmsk->dccpms_pending);
 	INIT_LIST_HEAD(&dmsk->dccpms_conf);
 
 	/* CCID L */
-	rc = __dccp_feat_init(sk, DCCPO_CHANGE_L, DCCPF_CCID,
+	rc = __dccp_feat_init(dmsk, DCCPO_CHANGE_L, DCCPF_CCID,
 			      &dmsk->dccpms_tx_ccid, 1);
 	if (rc)
 		goto out;
 
 	/* CCID R */
-	rc = __dccp_feat_init(sk, DCCPO_CHANGE_R, DCCPF_CCID,
+	rc = __dccp_feat_init(dmsk, DCCPO_CHANGE_R, DCCPF_CCID,
 			      &dmsk->dccpms_rx_ccid, 1);
 	if (rc)
 		goto out;
 
 	/* Ack ratio */
-	rc = __dccp_feat_init(sk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
+	rc = __dccp_feat_init(dmsk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
 			      &dmsk->dccpms_ack_ratio, 1);
 out:
 	return rc;
diff --git a/net/dccp/feat.h b/net/dccp/feat.h
index f7c73a3..11e92ec 100644
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -14,15 +14,16 @@
 #include <linux/types.h>
 
 struct sock;
+struct dccp_minisock;
 
-extern int  dccp_feat_change(struct sock *sk, u8 type, u8 feature, 
+extern int  dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature, 
 			     u8 *val, u8 len, gfp_t gfp);
 extern int  dccp_feat_change_recv(struct sock *sk, u8 type, u8 feature,
 				  u8 *val, u8 len);
 extern int  dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
 				   u8 *val, u8 len);
-extern void dccp_feat_clean(struct sock *sk);
+extern void dccp_feat_clean(struct dccp_minisock *dmsk);
 extern int  dccp_feat_clone(struct sock *oldsk, struct sock *newsk);
-extern int  dccp_feat_init(struct sock *sk);
+extern int  dccp_feat_init(struct dccp_minisock *dmsk);
 
 #endif /* _DCCP_FEAT_H */
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d637b94..0b26ea0 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -180,7 +180,7 @@ int dccp_init_sock(struct sock *sk, cons
 	 * setsockopt(CCIDs-I-want/accept). -acme
 	 */
 	if (likely(ctl_sock_initialized)) {
-		int rc = dccp_feat_init(sk);
+		int rc = dccp_feat_init(dmsk);
 
 		if (rc)
 			return rc;
@@ -229,6 +229,7 @@ EXPORT_SYMBOL_GPL(dccp_init_sock);
 int dccp_destroy_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 
 	/*
 	 * DCCP doesn't use sk_write_queue, just sk_send_head
@@ -246,7 +247,7 @@ int dccp_destroy_sock(struct sock *sk)
 	kfree(dp->dccps_service_list);
 	dp->dccps_service_list = NULL;
 
-	if (dccp_msk(sk)->dccpms_send_ack_vector) {
+	if (dmsk->dccpms_send_ack_vector) {
 		dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
 		dp->dccps_hc_rx_ackvec = NULL;
 	}
@@ -255,7 +256,7 @@ int dccp_destroy_sock(struct sock *sk)
 	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
 
 	/* clean up feature negotiation state */
-	dccp_feat_clean(sk);
+	dccp_feat_clean(dmsk);
 
 	return 0;
 }
@@ -441,8 +442,8 @@ static int dccp_setsockopt_change(struct
 		goto out_free_val;
 	}
 
-	rc = dccp_feat_change(sk, type, opt.dccpsf_feat, val, opt.dccpsf_len,
-			      GFP_KERNEL);
+	rc = dccp_feat_change(dccp_msk(sk), type, opt.dccpsf_feat,
+			      val, opt.dccpsf_len, GFP_KERNEL);
 	if (rc)
 		goto out_free_val;
 
-- 
1.2.2.gd27d


