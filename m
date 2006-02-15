From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Wed, 15 Feb 2006 12:49:47 +0000
Subject: [PATCH 1/X] [DCCP]: Actually change the CCID upon negotiation.
Message-Id: <20060215124946.GA5643@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Change the CCID upon successful feature negotiation.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index fb74260..094f1ba 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -14,6 +14,7 @@
 #include <linux/module.h>
 
 #include "dccp.h"
+#include "ccid.h"
 #include "feat.h"
 
 #define DCCP_FEAT_SP_NOAGREE (-123)
@@ -26,6 +27,8 @@ int dccp_feat_change(struct sock *sk, u8
 	
 	dccp_pr_debug("feat change type=%d feat=%d\n", type, feature);
 
+	/* XXX sanity check feat change request */
+
 	/* check if that feature is already being negotiated */
 	list_for_each_entry(opt, &dp->dccps_options.dccpo_pending,
 			    dccpop_node) {
@@ -62,11 +65,81 @@ int dccp_feat_change(struct sock *sk, u8
 
 EXPORT_SYMBOL_GPL(dccp_feat_change);
 
+static int dccp_feat_update_ccid(struct sock *sk, u8 type, u8 val)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct ccid **ccid;
+	u8 *oldval;
+	/* XXX function ptrs to inline functions.  Is this legal? */
+	int  (*ccid_hc_init)(struct ccid *ccid, struct sock *sk);
+	void (*ccid_hc_exit)(struct ccid *ccid, struct sock *sk);
+	int rc = 0;
+
+	/* figure out if we are changing our CCID or the peer's */	
+	if (type = DCCPO_CHANGE_L) {
+		ccid = &dp->dccps_hc_tx_ccid;
+		oldval = &dp->dccps_options.dccpo_tx_ccid;
+		ccid_hc_init = &ccid_hc_tx_init;
+		ccid_hc_exit = &ccid_hc_tx_exit;
+	} else {
+		ccid = &dp->dccps_hc_rx_ccid;
+		oldval = &dp->dccps_options.dccpo_rx_ccid;
+		ccid_hc_init = &ccid_hc_rx_init;
+		ccid_hc_exit = &ccid_hc_rx_exit;
+	}
+
+	/* check if nothing is being changed. */
+	if (*oldval = val)
+		return 0;
+
+	/* kill old CCID */
+	/* ccid_hc_init() is called only upon receiving a RESPONSE packet */
+	if (sk->sk_state != DCCP_REQUESTING)
+		ccid_hc_exit(*ccid, sk);
+	ccid_exit(*ccid, sk);
+	
+	/* switch CCID */
+	*ccid = ccid_init(val, sk);
+	if (*ccid = NULL) {
+		/* XXX OK we have a problem here.  socket will remain without
+		 * CCID.  I think the only sensible thing is to kill the socket
+		 * ASAP.  Ideally, one would make sure the new CCID could be
+		 * allocated before the old one is deleted.  The problem is that
+		 * ccid_init might play with the private ccid state of sk,
+		 * that's why it's safer to first kill the old ccid.
+		 */
+		rc = -ENOMEM;
+		goto out_exit;
+	}
+	if (sk->sk_state != DCCP_REQUESTING) {
+		rc = ccid_hc_init(*ccid, sk);
+		if (rc)
+			goto out_exit;
+	}
+	
+	*oldval = val;
+
+out:
+	return rc;
+out_exit:
+	ccid_exit(*ccid, sk);
+	*ccid = NULL;
+	goto out;
+}
+
 /* XXX taking only u8 vals */
 static int dccp_feat_update(struct sock *sk, u8 type, u8 feat, u8 val)
 {
-	/* FIXME implement */
 	dccp_pr_debug("changing [%d] feat %d to %d\n", type, feat, val);
+
+	switch (feat) {
+	case DCCPF_CCID:
+		return dccp_feat_update_ccid(sk, type, val);
+
+	default:
+		WARN_ON(1); /* XXX implement */
+		break;
+	}
 	return 0;
 }
 
