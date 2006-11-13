From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Nov 2006 13:27:52 +0000
Subject: [PATCH 4/7]: Introduce a consistent naming scheme for sysctls
Message-Id: <200611131327.52844@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Introduce a consistent naming scheme for sysctls

In order to make their function clearer and obtain a consistent naming
scheme to identify sysctls, all existing DCCP sysctls have been prefixed
with `sysctl_dccp', following the same convention as used by TCP.

Feature-specific sysctls retain the `feat' in the middle, although the
`default' has been dropped, since it is obvious from use.

Also removed a duplicate `dccp_feat_default_sequence_window' in ipv4.c.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h      |   12 ++++++------
 net/dccp/ipv4.c      |    1 -
 net/dccp/minisocks.c |    2 +-
 net/dccp/options.c   |   26 +++++++++++++-------------
 net/dccp/sysctl.c    |   24 ++++++++++++------------
 5 files changed, 32 insertions(+), 33 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -73,12 +73,12 @@ extern void dccp_time_wait(struct sock *
 extern int  sysctl_dccp_request_retries;
 extern int  sysctl_dccp_retries1;
 extern int  sysctl_dccp_retries2;
-extern int  dccp_feat_default_sequence_window;
-extern int  dccp_feat_default_rx_ccid;
-extern int  dccp_feat_default_tx_ccid;
-extern int  dccp_feat_default_ack_ratio;
-extern int  dccp_feat_default_send_ack_vector;
-extern int  dccp_feat_default_send_ndp_count;
+extern int  sysctl_dccp_feat_sequence_window;
+extern int  sysctl_dccp_feat_rx_ccid;
+extern int  sysctl_dccp_feat_tx_ccid;
+extern int  sysctl_dccp_feat_ack_ratio;
+extern int  sysctl_dccp_feat_send_ack_vector;
+extern int  sysctl_dccp_feat_send_ndp_count;
 
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -22,23 +22,23 @@
 #include "dccp.h"
 #include "feat.h"
 
-int dccp_feat_default_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
-int dccp_feat_default_rx_ccid	      = DCCPF_INITIAL_CCID;
-int dccp_feat_default_tx_ccid	      = DCCPF_INITIAL_CCID;
-int dccp_feat_default_ack_ratio	      = DCCPF_INITIAL_ACK_RATIO;
-int dccp_feat_default_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
-int dccp_feat_default_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
+int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
+int sysctl_dccp_feat_rx_ccid	      = DCCPF_INITIAL_CCID;
+int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
+int sysctl_dccp_feat_ack_ratio	      = DCCPF_INITIAL_ACK_RATIO;
+int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
+int sysctl_dccp_feat_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
 
-EXPORT_SYMBOL_GPL(dccp_feat_default_sequence_window);
+EXPORT_SYMBOL_GPL(sysctl_dccp_feat_sequence_window);
 
 void dccp_minisock_init(struct dccp_minisock *dmsk)
 {
-	dmsk->dccpms_sequence_window = dccp_feat_default_sequence_window;
-	dmsk->dccpms_rx_ccid	     = dccp_feat_default_rx_ccid;
-	dmsk->dccpms_tx_ccid	     = dccp_feat_default_tx_ccid;
-	dmsk->dccpms_ack_ratio	     = dccp_feat_default_ack_ratio;
-	dmsk->dccpms_send_ack_vector = dccp_feat_default_send_ack_vector;
-	dmsk->dccpms_send_ndp_count  = dccp_feat_default_send_ndp_count;
+	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
+	dmsk->dccpms_rx_ccid	     = sysctl_dccp_feat_rx_ccid;
+	dmsk->dccpms_tx_ccid	     = sysctl_dccp_feat_tx_ccid;
+	dmsk->dccpms_ack_ratio	     = sysctl_dccp_feat_ack_ratio;
+	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
+	dmsk->dccpms_send_ndp_count  = sysctl_dccp_feat_send_ndp_count;
 }
 
 static u32 dccp_decode_value_var(const unsigned char *bf, const u8 len)
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -21,48 +21,48 @@ static struct ctl_table dccp_default_tab
 	{
 		.ctl_name	= NET_DCCP_DEFAULT_SEQ_WINDOW,
 		.procname	= "seq_window",
-		.data		= &dccp_feat_default_sequence_window,
-		.maxlen		= sizeof(dccp_feat_default_sequence_window),
+		.data		= &sysctl_dccp_feat_sequence_window,
+		.maxlen		= sizeof(sysctl_dccp_feat_sequence_window),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_DCCP_DEFAULT_RX_CCID,
 		.procname	= "rx_ccid",
-		.data		= &dccp_feat_default_rx_ccid,
-		.maxlen		= sizeof(dccp_feat_default_rx_ccid),
+		.data		= &sysctl_dccp_feat_rx_ccid,
+		.maxlen		= sizeof(sysctl_dccp_feat_rx_ccid),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_DCCP_DEFAULT_TX_CCID,
 		.procname	= "tx_ccid",
-		.data		= &dccp_feat_default_tx_ccid,
-		.maxlen		= sizeof(dccp_feat_default_tx_ccid),
+		.data		= &sysctl_dccp_feat_tx_ccid,
+		.maxlen		= sizeof(sysctl_dccp_feat_tx_ccid),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_DCCP_DEFAULT_ACK_RATIO,
 		.procname	= "ack_ratio",
-		.data		= &dccp_feat_default_ack_ratio,
-		.maxlen		= sizeof(dccp_feat_default_ack_ratio),
+		.data		= &sysctl_dccp_feat_ack_ratio,
+		.maxlen		= sizeof(sysctl_dccp_feat_ack_ratio),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_DCCP_DEFAULT_SEND_ACKVEC,
 		.procname	= "send_ackvec",
-		.data		= &dccp_feat_default_send_ack_vector,
-		.maxlen		= sizeof(dccp_feat_default_send_ack_vector),
+		.data		= &sysctl_dccp_feat_send_ack_vector,
+		.maxlen		= sizeof(sysctl_dccp_feat_send_ack_vector),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_DCCP_DEFAULT_SEND_NDP,
 		.procname	= "send_ndp",
-		.data		= &dccp_feat_default_send_ndp_count,
-		.maxlen		= sizeof(dccp_feat_default_send_ndp_count),
+		.data		= &sysctl_dccp_feat_send_ndp_count,
+		.maxlen		= sizeof(sysctl_dccp_feat_send_ndp_count),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -648,7 +648,6 @@ int dccp_v4_conn_request(struct sock *sk
 	ireq = inet_rsk(req);
 	ireq->loc_addr = skb->nh.iph->daddr;
 	ireq->rmt_addr = skb->nh.iph->saddr;
-	req->rcv_wnd	= dccp_feat_default_sequence_window;
 	ireq->opt	= NULL;
 
 	/* 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -300,7 +300,7 @@ void dccp_reqsk_init(struct request_sock
 {
 	inet_rsk(req)->rmt_port = dccp_hdr(skb)->dccph_sport;
 	inet_rsk(req)->acked	= 0;
-	req->rcv_wnd		= dccp_feat_default_sequence_window;
+	req->rcv_wnd		= sysctl_dccp_feat_sequence_window;
 }
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_init);
