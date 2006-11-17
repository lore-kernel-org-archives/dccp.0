From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 17 Nov 2006 01:49:08 +0000
Subject: [PATCH 1/2] [DCCP]: Implement tx_qlen sysctl
Message-Id: <200611171449.11919.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This implements tx buffer sysctls for DCCP.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index c2328c8..b452ff8 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -104,6 +104,10 @@ rx_ccid = 2
 seq_window = 100
 	The initial sequence window (sec. 7.5.2).
 
+tx_qlen = 5
+	The size of the transmit buffer in packets. A value of 0 corresponds
+	to an unbounded transmit buffer.
+
 Notes
 == 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index d98562f..4db45ec 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -612,6 +612,7 @@ enum {
 	NET_DCCP_DEFAULT_ACK_RATIO   = 4,
 	NET_DCCP_DEFAULT_SEND_ACKVEC = 5,
 	NET_DCCP_DEFAULT_SEND_NDP    = 6,
+	NET_DCCP_TX_QLEN             = 10,
 };
 
 /* /proc/sys/net/ipx */
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 6e557d8..ff2b77d 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -61,6 +61,10 @@ extern void dccp_time_wait(struct sock *
 #define DCCP_XMIT_TIMEO 30000
 /* Time in msecs for blocking transmit per packet */
 
+#define DCCP_DEFAULT_TX_QLEN 5
+
+extern int sysctl_dccp_tx_qlen;
+
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 72cbdcf..2729fdc 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -52,6 +52,9 @@ struct inet_hashinfo __cacheline_aligned
 
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
+/* the maximum queue length for tx in packets. 0 is no limit */
+int sysctl_dccp_tx_qlen;
+
 void dccp_set_state(struct sock *sk, const int state)
 {
 	const int oldstate = sk->sk_state;
@@ -1040,6 +1043,8 @@ static int __init dccp_init(void)
 		INIT_HLIST_HEAD(&dccp_hashinfo.bhash[i].chain);
 	}
 
+	sysctl_dccp_tx_qlen = DCCP_DEFAULT_TX_QLEN;
+
 	rc = dccp_mib_init();
 	if (rc)
 		goto out_free_dccp_bhash;
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index 38bc157..8aa8f30 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -11,6 +11,7 @@
 
 #include <linux/mm.h>
 #include <linux/sysctl.h>
+#include "dccp.h"
 #include "feat.h"
 
 #ifndef CONFIG_SYSCTL
@@ -66,6 +67,15 @@ static struct ctl_table dccp_default_tab
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_DCCP_TX_QLEN,
+		.procname	= "tx_qlen",
+		.data		= &sysctl_dccp_tx_qlen,
+		.maxlen		= sizeof(sysctl_dccp_tx_qlen),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+
 	{ .ctl_name = 0, }
 };
 
