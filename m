From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Wed, 15 Nov 2006 21:37:30 +0000
Subject: [RFC PATCH 1/2]: DCCP Introduce tx queue limits
Message-Id: <200611161037.32393.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

Here is something I've whipped up. Just wondering about your thoughts on this? I think it makes more sense to do by packets queued rather than bytes as it is a datagram based protocol.

Notes:
- Compile tested only
- Probably won't apply to latest tree (sorry about that - will fix before I ask to merge)

Appreciate feedback.

This implements tx buffer sysctls for DCCP.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
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
index 6e557d8..27790fb 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -61,6 +61,8 @@ extern void dccp_time_wait(struct sock *
 #define DCCP_XMIT_TIMEO 30000
 /* Time in msecs for blocking transmit per packet */
 
+extern int sysctl_dccp_tx_qlen;
+
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 72cbdcf..b9d6e7e 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -52,6 +52,10 @@ struct inet_hashinfo __cacheline_aligned
 
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
+int sysctl_dccp_tx_qlen;
+
+EXPORT_SYMBOL_GPL(sysctl_dccp_tx_qlen);
+
 void dccp_set_state(struct sock *sk, const int state)
 {
 	const int oldstate = sk->sk_state;
@@ -1040,6 +1044,8 @@ static int __init dccp_init(void)
 		INIT_HLIST_HEAD(&dccp_hashinfo.bhash[i].chain);
 	}
 
+	sysctl_dccp_tx_qlen = 6; /* number that sounds about right */
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
 
