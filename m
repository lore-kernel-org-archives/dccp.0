From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Nov 2006 21:57:53 +0000
Subject: [PATCH 1/7] [DCCP]: Remove allocation of sysctl numbers
Message-Id: <20061128215752.GJ19882@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is in response to a request sent earlier by Eric W. Biederman
and replaces all sysctl numbers for net.dccp.default with CTL_UNNUMBERED.

It has been tested to compile and to work.

Commiter note: I've removed the use of CTL_UNNUMBERED, not setting .ctl_name
               sets it to 0, that is the what CTL_UNNUMBERED is, reason is
               to avoid unneeded source code cluttering.

Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/linux/sysctl.h |   14 --------------
 net/dccp/sysctl.c      |   10 ----------
 2 files changed, 0 insertions(+), 24 deletions(-)

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
index 4775ba3..fdcfca3 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -20,7 +20,6 @@ #endif
 
 static struct ctl_table dccp_default_table[] = {
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_SEQ_WINDOW,
 		.procname	= "seq_window",
 		.data		= &sysctl_dccp_feat_sequence_window,
 		.maxlen		= sizeof(sysctl_dccp_feat_sequence_window),
@@ -28,7 +27,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_RX_CCID,
 		.procname	= "rx_ccid",
 		.data		= &sysctl_dccp_feat_rx_ccid,
 		.maxlen		= sizeof(sysctl_dccp_feat_rx_ccid),
@@ -36,7 +34,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_TX_CCID,
 		.procname	= "tx_ccid",
 		.data		= &sysctl_dccp_feat_tx_ccid,
 		.maxlen		= sizeof(sysctl_dccp_feat_tx_ccid),
@@ -44,7 +41,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_ACK_RATIO,
 		.procname	= "ack_ratio",
 		.data		= &sysctl_dccp_feat_ack_ratio,
 		.maxlen		= sizeof(sysctl_dccp_feat_ack_ratio),
@@ -52,7 +48,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_SEND_ACKVEC,
 		.procname	= "send_ackvec",
 		.data		= &sysctl_dccp_feat_send_ack_vector,
 		.maxlen		= sizeof(sysctl_dccp_feat_send_ack_vector),
@@ -60,7 +55,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_SEND_NDP,
 		.procname	= "send_ndp",
 		.data		= &sysctl_dccp_feat_send_ndp_count,
 		.maxlen		= sizeof(sysctl_dccp_feat_send_ndp_count),
@@ -68,7 +62,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_REQ_RETRIES,
 		.procname	= "request_retries",
 		.data		= &sysctl_dccp_request_retries,
 		.maxlen		= sizeof(sysctl_dccp_request_retries),
@@ -76,7 +69,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_RETRIES1,
 		.procname	= "retries1",
 		.data		= &sysctl_dccp_retries1,
 		.maxlen		= sizeof(sysctl_dccp_retries1),
@@ -84,7 +76,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_RETRIES2,
 		.procname	= "retries2",
 		.data		= &sysctl_dccp_retries2,
 		.maxlen		= sizeof(sysctl_dccp_retries2),
@@ -92,7 +83,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_DCCP_DEFAULT_TX_QLEN,
 		.procname	= "tx_qlen",
 		.data		= &sysctl_dccp_tx_qlen,
 		.maxlen		= sizeof(sysctl_dccp_tx_qlen),
-- 
1.4.2.1.g3d5c

