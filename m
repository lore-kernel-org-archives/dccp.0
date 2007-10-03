From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:38 +0000
Subject: [PATCH 5/14]: Clean up remains from old feature-negotiation infrastructure
Message-Id: <200710031502.38598@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Clean up remains from old feature-negotiation infrastructure

The code removed by this patch is no longer referenced or used, the added
lines update documentation and copyrights.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c  |   95 +++----------------------------------------------------
 net/dccp/feat.h  |   12 ++----
 net/dccp/proto.c |    1 
 3 files changed, 11 insertions(+), 97 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1,8 +1,12 @@
 /*
  *  net/dccp/feat.c
  *
- *  An implementation of the DCCP protocol
- *  Andrea Bittau <a.bittau@cs.ucl.ac.uk>
+ *  Feature negotiation for the DCCP protocol (RFC 4340, section 6)
+ *
+ *  Copyright (c) 2007 Gerrit Renker <gerrit@erg.abdn.ac.uk>
+ *  Rewrote from scratch, some bits from earlier code by
+ *  Copyright (c) 2005 Andrea Bittau <a.bittau@cs.ucl.ac.uk>
+ *
  *
  *  ASSUMPTIONS
  *  -----------
@@ -17,9 +21,7 @@
  *  as published by the Free Software Foundation; either version
  *  2 of the License, or (at your option) any later version.
  */
-
 #include <linux/module.h>
-
 #include "ccid.h"
 #include "feat.h"
 
@@ -1014,91 +1016,6 @@ int dccp_feat_parse_options(struct sock 
 	return 0;	/* ignore FN options in all other states */
 }
 
-void dccp_feat_clean(struct dccp_minisock *dmsk)
-{
-	struct dccp_opt_pend *opt, *next;
-
-	list_for_each_entry_safe(opt, next, &dmsk->dccpms_pending,
-				 dccpop_node) {
-		BUG_ON(opt->dccpop_val = NULL);
-		kfree(opt->dccpop_val);
-
-		if (opt->dccpop_sc != NULL) {
-			BUG_ON(opt->dccpop_sc->dccpoc_val = NULL);
-			kfree(opt->dccpop_sc->dccpoc_val);
-			kfree(opt->dccpop_sc);
-		}
-
-		kfree(opt);
-	}
-	INIT_LIST_HEAD(&dmsk->dccpms_pending);
-
-	list_for_each_entry_safe(opt, next, &dmsk->dccpms_conf, dccpop_node) {
-		BUG_ON(opt = NULL);
-		if (opt->dccpop_val != NULL)
-			kfree(opt->dccpop_val);
-		kfree(opt);
-	}
-	INIT_LIST_HEAD(&dmsk->dccpms_conf);
-}
-
-EXPORT_SYMBOL_GPL(dccp_feat_clean);
-
-/* this is to be called only when a listening sock creates its child.  It is
- * assumed by the function---the confirm is not duplicated, but rather it is
- * "passed on".
- */
-int dccp_feat_clone(struct sock *oldsk, struct sock *newsk)
-{
-	struct dccp_minisock *olddmsk = dccp_msk(oldsk);
-	struct dccp_minisock *newdmsk = dccp_msk(newsk);
-	struct dccp_opt_pend *opt;
-	int rc = 0;
-
-	INIT_LIST_HEAD(&newdmsk->dccpms_pending);
-	INIT_LIST_HEAD(&newdmsk->dccpms_conf);
-
-	list_for_each_entry(opt, &olddmsk->dccpms_pending, dccpop_node) {
-		struct dccp_opt_pend *newopt;
-		/* copy the value of the option */
-		u8 *val = kmemdup(opt->dccpop_val, opt->dccpop_len, GFP_ATOMIC);
-
-		if (val = NULL)
-			goto out_clean;
-
-		newopt = kmemdup(opt, sizeof(*newopt), GFP_ATOMIC);
-		if (newopt = NULL) {
-			kfree(val);
-			goto out_clean;
-		}
-
-		/* insert the option */
-		newopt->dccpop_val = val;
-		list_add_tail(&newopt->dccpop_node, &newdmsk->dccpms_pending);
-
-		/* XXX what happens with backlogs and multiple connections at
-		 * once...
-		 */
-		/* the master socket no longer needs to worry about confirms */
-		opt->dccpop_sc = NULL; /* it's not a memleak---new socket has it */
-
-		/* reset state for a new socket */
-		opt->dccpop_conf = 0;
-	}
-
-	/* XXX not doing anything about the conf queue */
-
-out:
-	return rc;
-
-out_clean:
-	dccp_feat_clean(newdmsk);
-	rc = -ENOMEM;
-	goto out;
-}
-
-EXPORT_SYMBOL_GPL(dccp_feat_clone);
-
 int dccp_feat_init(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -3,14 +3,14 @@
 /*
  *  net/dccp/feat.h
  *
- *  An implementation of the DCCP protocol
+ *  Feature negotiation for the DCCP protocol (RFC 4340, section 6)
+ *  Copyright (c) 2007 Gerrit Renker <gerrit@erg.abdn.ac.uk>
  *  Copyright (c) 2005 Andrea Bittau <a.bittau@cs.ucl.ac.uk>
  *
- *	This program is free software; you can redistribute it and/or modify it
- *	under the terms of the GNU General Public License version 2 as
- *	published by the Free Software Foundation.
+ *  This program is free software; you can redistribute it and/or modify it
+ *  under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
  */
-
 #include <linux/types.h>
 #include "dccp.h"
 
@@ -105,8 +105,6 @@ extern int  dccp_feat_register_change(st
 				      u8 is_local, u8 *val, u8 len);
 extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
 				    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
-extern void dccp_feat_clean(struct dccp_minisock *dmsk);
-extern int  dccp_feat_clone(struct sock *oldsk, struct sock *newsk);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
 extern int  dccp_feat_init(struct sock *sk);
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -234,7 +234,6 @@ int dccp_destroy_sock(struct sock *sk)
 	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
 
 	/* clean up feature negotiation state */
-	dccp_feat_clean(dmsk);
 	dccp_feat_list_purge(&dp->dccps_featneg);
 
 	return 0;
