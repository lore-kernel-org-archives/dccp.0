From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 26 Jul 2007 12:56:39 +0000
Subject: [PATCH 2/5]: Tidy-up -- minisock initialisation
Message-Id: <200707261356.39826@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Tidy-up -- minisock initialisation

This 
 * removes a declaration of a non-existent function __dccp_minisock_init;
 * shifts the initialisation function dccp_minisock_init() from options.c
   to minisocks.c, where it is more naturally expected to be.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>   
---
 include/linux/dccp.h |    1 -
 net/dccp/minisocks.c |   10 ++++++++++
 net/dccp/options.c   |   10 ----------
 3 files changed, 10 insertions(+), 11 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -406,7 +406,6 @@ struct dccp_opt_pend {
 	struct dccp_opt_conf    *dccpop_sc;
 };
 
-extern void __dccp_minisock_init(struct dccp_minisock *dmsk);
 extern void dccp_minisock_init(struct dccp_minisock *dmsk);
 
 extern int dccp_parse_options(struct sock *sk, struct sk_buff *skb);
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -42,6 +42,16 @@ struct inet_timewait_death_row dccp_deat
 
 EXPORT_SYMBOL_GPL(dccp_death_row);
 
+void dccp_minisock_init(struct dccp_minisock *dmsk)
+{
+	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
+	dmsk->dccpms_rx_ccid	     = sysctl_dccp_feat_rx_ccid;
+	dmsk->dccpms_tx_ccid	     = sysctl_dccp_feat_tx_ccid;
+	dmsk->dccpms_ack_ratio	     = sysctl_dccp_feat_ack_ratio;
+	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
+	dmsk->dccpms_send_ndp_count  = sysctl_dccp_feat_send_ndp_count;
+}
+
 void dccp_time_wait(struct sock *sk, int state, int timeo)
 {
 	struct inet_timewait_sock *tw = NULL;
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -23,16 +23,6 @@
 #include "dccp.h"
 #include "feat.h"
 
-void dccp_minisock_init(struct dccp_minisock *dmsk)
-{
-	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
-	dmsk->dccpms_rx_ccid	     = sysctl_dccp_feat_rx_ccid;
-	dmsk->dccpms_tx_ccid	     = sysctl_dccp_feat_tx_ccid;
-	dmsk->dccpms_ack_ratio	     = sysctl_dccp_feat_ack_ratio;
-	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
-	dmsk->dccpms_send_ndp_count  = sysctl_dccp_feat_send_ndp_count;
-}
-
 static u32 dccp_decode_value_var(const unsigned char *bf, const u8 len)
 {
 	u32 value = 0;
