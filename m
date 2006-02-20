From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 20 Feb 2006 12:43:01 +0000
Subject: [PATCH 2/2][DCCP] feat: Actually change the CCID upon negotiation
Message-Id: <39e6f6c70602200443rcf4f551o3a7af75d848d2a80@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_10499_12369112.1140439381775"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_10499_12369112.1140439381775
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

 Please consider pulling from the "dccp_upstream" branch of:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

 Now there are two outstanding csets in this tree.

Best Regards,

- Arnaldo

------=_Part_10499_12369112.1140439381775
Content-Type: text/x-patch; name=2.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ejws2izn
Content-Disposition: attachment; filename="2.patch"

tree 4ec67bef992ff59201add0d15e0e2be7c259d810
parent dd44614e443c8cb99187b26f4b82742d0f0aead2
author Andrea Bittau <a.bittau@cs.ucl.ac.uk> 1140438471 -0300
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1140438471 -0300

[DCCP] feat: Actually change the CCID upon negotiation

Change the CCID upon successful feature negotiation.

Commiter note: patch mostly rewritten to use the new ccid API.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 feat.c |   43 ++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 42 insertions(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index fb74260..0ab5f84 100644
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
@@ -62,11 +65,49 @@ int dccp_feat_change(struct sock *sk, u8
 
 EXPORT_SYMBOL_GPL(dccp_feat_change);
 
+static int dccp_feat_update_ccid(struct sock *sk, u8 type, u8 new_ccid_nr)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	/* figure out if we are changing our CCID or the peer's */	
+	const int rx = type == DCCPO_CHANGE_R;
+	const u8 ccid_nr = rx ? dp->dccps_options.dccpo_rx_ccid :
+				dp->dccps_options.dccpo_tx_ccid;
+	struct ccid *new_ccid;
+
+	/* Check if nothing is being changed. */
+	if (ccid_nr == new_ccid_nr)
+		return 0;
+
+	new_ccid = ccid_new(new_ccid_nr, sk, rx, GFP_ATOMIC);
+	if (new_ccid == NULL)
+		return -ENOMEM;
+	
+	if (rx) {
+		ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
+		dp->dccps_hc_rx_ccid = new_ccid;
+		dp->dccps_options.dccpo_rx_ccid = new_ccid_nr;
+	} else {
+		ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
+		dp->dccps_hc_tx_ccid = new_ccid;
+		dp->dccps_options.dccpo_tx_ccid = new_ccid_nr;
+	}
+
+	return 0;
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
+	default:
+		dccp_pr_debug("IMPLEMENT changing [%d] feat %d to %d\n",
+			      type, feat, val);
+		break;
+	}
 	return 0;
 }
 


------=_Part_10499_12369112.1140439381775--
