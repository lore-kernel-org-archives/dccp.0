From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Jan 2009 09:36:32 +0000
Subject: [PATCH 3/4] dccp: Initialisation and type-checking of feature sysctls
Message-Id: <1232184993-9927-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch takes care of initialising and type-checking sysctls related to
feature negotiation. Type checking is important since some of the sysctls
now directly impact the feature-negotiation process.

The sysctls are initialised with the known default values for each feature.
For the type-checking the value constraints from RFC 4340 are used:

 * Sequence Window uses the specified Wmin2, the maximum is ulong (4 bytes),
   tested and confirmed that it works up to 4294967295 - for Gbps speed;
 * Ack Ratio is between 0 .. 0xffff (2-byte unsigned integer);
 * CCIDs are between 0 .. 255;
 * request_retries, retries1, retries2 also between 0..255 for good measure;
 * tx_qlen is checked to be non-negative;
 * sync_ratelimit remains as before.

Notes: 
------
 1. Die s@sysctl_dccp_feat@sysctl_dccp@g since the sysctls are now in feat.c.
 2. As pointed out by Arnaldo, the pattern of type-checking repeats itself in
    other places, sometimes with exactly the same kind of definitions (e.g. 
    "static int zero;"). It may be a good idea (kernel janitors?) to consolidate
    type checking. For the sake of keeping the changeset small and in order not
    to affect other subsystems, I have not strived to generalise here.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 include/linux/dccp.h |    8 --------
 net/dccp/dccp.h      |    3 ---
 net/dccp/feat.c      |   11 ++++++++---
 net/dccp/feat.h      |    8 ++++++++
 net/dccp/options.c   |    4 ----
 net/dccp/sysctl.c    |   43 ++++++++++++++++++++++++++++++-------------
 6 files changed, 46 insertions(+), 31 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -100,6 +100,13 @@ struct ccid_dependency {
 	u8	val;
 };
 
+/*
+ * Sysctls to seed defaults for feature negotiation
+ */
+extern unsigned long sysctl_dccp_sequence_window;
+extern int	     sysctl_dccp_rx_ccid;
+extern int	     sysctl_dccp_tx_ccid;
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern const char *dccp_feat_typename(const u8 type);
 extern const char *dccp_feat_name(const u8 feat);
@@ -114,6 +121,7 @@ static inline void dccp_feat_debug(const
 #endif /* CONFIG_IP_DCCP_DEBUG */
 
 extern int  dccp_feat_init(struct sock *sk);
+extern void dccp_feat_initialise_sysctls(void);
 extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
 				  u8 const *list, u8 len);
 extern int  dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -25,6 +25,11 @@
 #include "ccid.h"
 #include "feat.h"
 
+/* feature-specific sysctls - initialised to the defaults from RFC 4340, 6.4 */
+unsigned long	sysctl_dccp_sequence_window __read_mostly = 100;
+int		sysctl_dccp_rx_ccid	    __read_mostly = 2,
+		sysctl_dccp_tx_ccid	    __read_mostly = 2;
+
 /*
  * Feature activation handlers.
  *
@@ -1146,7 +1151,7 @@ int dccp_feat_init(struct sock *sk)
 
 	/* Non-negotiable (NN) features */
 	rc = __feat_register_nn(fn, DCCPF_SEQUENCE_WINDOW, 0,
-				    sysctl_dccp_feat_sequence_window);
+				    sysctl_dccp_sequence_window);
 	if (rc)
 		return rc;
 
@@ -1172,8 +1177,8 @@ int dccp_feat_init(struct sock *sk)
 	    ccid_get_builtin_ccids(&rx.val, &rx.len))
 		return -ENOBUFS;
 
-	if (!dccp_feat_prefer(sysctl_dccp_feat_tx_ccid, tx.val, tx.len) ||
-	    !dccp_feat_prefer(sysctl_dccp_feat_rx_ccid, rx.val, rx.len))
+	if (!dccp_feat_prefer(sysctl_dccp_tx_ccid, tx.val, tx.len) ||
+	    !dccp_feat_prefer(sysctl_dccp_rx_ccid, rx.val, rx.len))
 		goto free_ccid_lists;
 
 	rc = __feat_register_sp(fn, DCCPF_CCID, true, false, tx.val, tx.len);
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -18,55 +18,72 @@
 #error This file should not be compiled without CONFIG_SYSCTL defined
 #endif
 
+/* Boundary values */
+static int		zero     = 0,
+			u8_max   = 0xFF;
+static unsigned long	seqw_min = 32;
+
 static struct ctl_table dccp_default_table[] = {
 	{
 		.procname	= "seq_window",
-		.data		= &sysctl_dccp_feat_sequence_window,
-		.maxlen		= sizeof(sysctl_dccp_feat_sequence_window),
+		.data		= &sysctl_dccp_sequence_window,
+		.maxlen		= sizeof(sysctl_dccp_sequence_window),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1		= &seqw_min,		/* RFC 4340, 7.5.2 */
 	},
 	{
 		.procname	= "rx_ccid",
-		.data		= &sysctl_dccp_feat_rx_ccid,
-		.maxlen		= sizeof(sysctl_dccp_feat_rx_ccid),
+		.data		= &sysctl_dccp_rx_ccid,
+		.maxlen		= sizeof(sysctl_dccp_rx_ccid),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &u8_max,		/* RFC 4340, 10. */
 	},
 	{
 		.procname	= "tx_ccid",
-		.data		= &sysctl_dccp_feat_tx_ccid,
-		.maxlen		= sizeof(sysctl_dccp_feat_tx_ccid),
+		.data		= &sysctl_dccp_tx_ccid,
+		.maxlen		= sizeof(sysctl_dccp_tx_ccid),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &u8_max,		/* RFC 4340, 10. */
 	},
 	{
 		.procname	= "request_retries",
 		.data		= &sysctl_dccp_request_retries,
 		.maxlen		= sizeof(sysctl_dccp_request_retries),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &u8_max,
 	},
 	{
 		.procname	= "retries1",
 		.data		= &sysctl_dccp_retries1,
 		.maxlen		= sizeof(sysctl_dccp_retries1),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &u8_max,
 	},
 	{
 		.procname	= "retries2",
 		.data		= &sysctl_dccp_retries2,
 		.maxlen		= sizeof(sysctl_dccp_retries2),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &u8_max,
 	},
 	{
 		.procname	= "tx_qlen",
 		.data		= &sysctl_dccp_tx_qlen,
 		.maxlen		= sizeof(sysctl_dccp_tx_qlen),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
 	},
 	{
 		.procname	= "sync_ratelimit",
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -355,14 +355,6 @@ static inline unsigned int dccp_hdr_len(
 	return __dccp_hdr_len(dccp_hdr(skb));
 }
 
-
-/* initial values for each feature */
-#define DCCPF_INITIAL_SEQUENCE_WINDOW		100
-#define DCCPF_INITIAL_ACK_RATIO			2
-#define DCCPF_INITIAL_CCID			DCCPC_CCID2
-/* FIXME: for now we're default to 1 but it should really be 0 */
-#define DCCPF_INITIAL_SEND_NDP_COUNT		1
-
 /**
  * struct dccp_request_sock  -  represent DCCP-specific connection request
  * @dreq_inet_rsk: structure inherited from
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -95,9 +95,6 @@ extern void dccp_time_wait(struct sock *
 extern int  sysctl_dccp_request_retries;
 extern int  sysctl_dccp_retries1;
 extern int  sysctl_dccp_retries2;
-extern int  sysctl_dccp_feat_sequence_window;
-extern int  sysctl_dccp_feat_rx_ccid;
-extern int  sysctl_dccp_feat_tx_ccid;
 extern int  sysctl_dccp_tx_qlen;
 extern int  sysctl_dccp_sync_ratelimit;
 
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -23,10 +23,6 @@
 #include "dccp.h"
 #include "feat.h"
 
-int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
-int sysctl_dccp_feat_rx_ccid	      = DCCPF_INITIAL_CCID;
-int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
-
 u64 dccp_decode_value_var(const u8 *bf, const u8 len)
 {
 	u64 value = 0;
