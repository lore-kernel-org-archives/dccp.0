From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 13 Dec 2007 15:06:04 +0000
Subject: [PATCH 11/12] [DCCP]: Make code assumptions explicit
Message-Id: <1197558365-31134-12-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This removes several `XXX' references which indicate a missing support
for non-1-byte feature values: this is unnecessary, as all currently known
(standardised) SP feature values are 1-byte quantities.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/feat.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 084744e..4a4f6ce 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -4,10 +4,16 @@
  *  An implementation of the DCCP protocol
  *  Andrea Bittau <a.bittau@cs.ucl.ac.uk>
  *
- *      This program is free software; you can redistribute it and/or
- *      modify it under the terms of the GNU General Public License
- *      as published by the Free Software Foundation; either version
- *      2 of the License, or (at your option) any later version.
+ *  ASSUMPTIONS
+ *  -----------
+ *  o All currently known SP features have 1-byte quantities. If in the future
+ *    extensions of RFCs 4340..42 define features with item lengths larger than
+ *    one byte, a feature-specific extension of the code will be required.
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version
+ *  2 of the License, or (at your option) any later version.
  */
 
 #include <linux/module.h>
@@ -95,7 +101,6 @@ static int dccp_feat_update_ccid(struct sock *sk, u8 type, u8 new_ccid_nr)
 	return 0;
 }
 
-/* XXX taking only u8 vals */
 static int dccp_feat_update(struct sock *sk, u8 type, u8 feat, u8 val)
 {
 	dccp_feat_debug(type, feat, val);
@@ -140,7 +145,6 @@ static int dccp_feat_reconcile(struct sock *sk, struct dccp_opt_pend *opt,
 	/* FIXME sanity check vals */
 
 	/* Are values in any order?  XXX Lame "algorithm" here */
-	/* XXX assume values are 1 byte */
 	for (i = 0; i < slen; i++) {
 		for (j = 0; j < rlen; j++) {
 			if (spref[i] = rpref[j]) {
@@ -175,7 +179,6 @@ static int dccp_feat_reconcile(struct sock *sk, struct dccp_opt_pend *opt,
 	}
 
 	/* need to put result and our preference list */
-	/* XXX assume 1 byte vals */
 	rlen = 1 + opt->dccpop_len;
 	rpref = kmalloc(rlen, GFP_ATOMIC);
 	if (rpref = NULL)
-- 
1.5.3.4

