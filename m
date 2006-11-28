From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 12:59:13 +0000
Subject: [PATCH] [DCCP]: Remove allocation of sysctl numbers
Message-Id: <200611281259.13546@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Remove allocation of sysctl numbers

This is in response to a request sent earlier by Eric W. Biederman
and replaces all sysctl numbers for net.dccp.default with CTL_UNNUMBERED.

It has been tested to compile and to work.

Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 include/linux/sysctl.h |   14 --------------
 net/dccp/sysctl.c      |   20 ++++++++++----------
 2 files changed, 10 insertions(+), 24 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 61dd99c..94316a9 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -606,20 +606,6 @@ enum {
 	NET_DCCP_DEFAULT=1,
 };
 
-/* /proc/sys/net/dccp/default */
-enum {
-	NET_DCCP_DEFAULT_SEQ_WINDOW  = 1,
-	NET_DCCP_DEFAULT_RX_CCID     = 2,
-	NET_DCCP_DEFAULT_TX_CCID     = 3,
-	NET_DCCP_DEFAULT_ACK_RATIO   = 4,
-	NET_DCCP_DEFAULT_SEND_ACKVEC = 5,
-	NET_DCCP_DEFAULT_SEND_NDP    = 6,
-	NET_DCCP_DEFAULT_REQ_RETRIES = 7,
-	NET_DCCP_DEFAULT_RETRIES1    = 8,
-	NET_DCCP_DEFAULT_RETRIES2    = 9,
-	NET_DCCP_DEFAULT_TX_QLEN     = 10,
-};
-
 /* /proc/sys/net/ipx */
 enum {
 	NET_IPX_PPROP_BROADCASTING=1,
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index 4775ba3..19e15bf 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -20,7 +20,7 @@ #endif
 
 static struct ctl_table dccp_default_table[] = {
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_SEQ_WINDOW,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "seq_window",
 		.data		= &sysctl_dccp_feat_sequence_window,
 		.maxlen		= sizeof(sysctl_dccp_feat_sequence_window),
@@ -28,7 +28,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_RX_CCID,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "rx_ccid",
 		.data		= &sysctl_dccp_feat_rx_ccid,
 		.maxlen		= sizeof(sysctl_dccp_feat_rx_ccid),
@@ -36,7 +36,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_TX_CCID,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "tx_ccid",
 		.data		= &sysctl_dccp_feat_tx_ccid,
 		.maxlen		= sizeof(sysctl_dccp_feat_tx_ccid),
@@ -44,7 +44,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_ACK_RATIO,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "ack_ratio",
 		.data		= &sysctl_dccp_feat_ack_ratio,
 		.maxlen		= sizeof(sysctl_dccp_feat_ack_ratio),
@@ -52,7 +52,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_SEND_ACKVEC,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "send_ackvec",
 		.data		= &sysctl_dccp_feat_send_ack_vector,
 		.maxlen		= sizeof(sysctl_dccp_feat_send_ack_vector),
@@ -60,7 +60,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_SEND_NDP,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "send_ndp",
 		.data		= &sysctl_dccp_feat_send_ndp_count,
 		.maxlen		= sizeof(sysctl_dccp_feat_send_ndp_count),
@@ -68,7 +68,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_REQ_RETRIES,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "request_retries",
 		.data		= &sysctl_dccp_request_retries,
 		.maxlen		= sizeof(sysctl_dccp_request_retries),
@@ -76,7 +76,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_RETRIES1,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "retries1",
 		.data		= &sysctl_dccp_retries1,
 		.maxlen		= sizeof(sysctl_dccp_retries1),
@@ -84,7 +84,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_RETRIES2,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "retries2",
 		.data		= &sysctl_dccp_retries2,
 		.maxlen		= sizeof(sysctl_dccp_retries2),
@@ -92,7 +92,7 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_TX_QLEN,
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "tx_qlen",
 		.data		= &sysctl_dccp_tx_qlen,
 		.maxlen		= sizeof(sysctl_dccp_tx_qlen),
