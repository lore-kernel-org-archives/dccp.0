From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Oct 2007 15:26:44 +0000
Subject: [Announce][PATCH v2 1/1]: Patch dropped / [DCCP]: Initialisation and type-checking of feature sysctl
Message-Id: <200710241626.44834@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

After discussion with Arnaldo, I have decided to remove the following patch from the test tree

------------------------------------------------------------------------------------------
 [DCCP]: Collect all scattered sysctl variables into sysctl.c

This
 1. organizes the sysctl variables which are scattered over many DCCP source
    files into sysctl.c - so that they can easier be found;
 2. wraps the compilation of the CONFIG_SYSCTL part into a conditional define
    - if not enabled, then only the variables will be `compiled';
 3. shortens the definitions of init/exit dummy functions in the header file.
------------------------------------------------------------------------------------------

As a result, several other patches needed re-adjustment. This involved mostly small changes;
the biggest is the patch reproduced below (please let me know if not ok with this, the patch
has only been re-adjusted, but its nature has not changed).

Compile tested the test tree on two different architectures (i386/sparc64).


----------------------------> Patch v2 <------------------------------
[DCCP]: Initialisation and type-checking of feature sysctls

The number of feature sysctls is now smaller (it is instead now possible
to set values on a per-connection basis via sockops); this patch takes care
of their initialisation and some rudimentary type-checking:
 
 * Sequence Window uses the specified Wmin2, the maximum is ulong (4 bytes), I have
   tested and confirmed that it works up to 4294967295 - let's use it for Gbps;
 * Ack Ratio is between 0 .. 0xFFFF (2-byte unsigned integer);
 * CCIDs are between 0 .. 255 (FIXME: write handler for available ones);
 * request_retries, retries1, retries2 also between 0..255 for good measure;
 * tx_qlen is checked to be non-negative;
 * sync_ratelimit remains as before.
 
The sysctls are initialised with the known default values for each feature
at boot or module load time; for the type-checking the value constraints from
RFC 4340 have been used. Type checking is important since some of the sysctls
now directly act on the feature-negotiation process.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 include/linux/dccp.h |    7 -------
 net/dccp/dccp.h      |    4 ----
 net/dccp/feat.c      |   18 ++++++++++++++++++
 net/dccp/feat.h      |   10 ++++++++++
 net/dccp/options.c   |    5 -----
 net/dccp/sysctl.c    |   36 ++++++++++++++++++++++++++++--------
 6 files changed, 56 insertions(+), 24 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -95,10 +95,6 @@ extern void dccp_time_wait(struct sock *
 extern int  sysctl_dccp_request_retries;
 extern int  sysctl_dccp_retries1;
 extern int  sysctl_dccp_retries2;
-extern int  sysctl_dccp_feat_sequence_window;
-extern int  sysctl_dccp_feat_rx_ccid;
-extern int  sysctl_dccp_feat_tx_ccid;
-extern int  sysctl_dccp_feat_ack_ratio;
 extern int  sysctl_dccp_tx_qlen;
 extern int  sysctl_dccp_sync_ratelimit;
 
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -368,13 +368,6 @@ static inline unsigned int dccp_hdr_len(
 }
 
 
-/* initial values for each feature */
-#define DCCPF_INITIAL_SEQUENCE_WINDOW		100
-#define DCCPF_INITIAL_ACK_RATIO			2
-#define DCCPF_INITIAL_CCID			DCCPC_CCID2
-/* FIXME: for now we're default to 1 but it should really be 0 */
-#define DCCPF_INITIAL_SEND_NDP_COUNT		1
-
 /**
   * struct dccp_minisock - Minimal DCCP connection representation
   *
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -88,6 +88,15 @@ struct ccid_dependency {
 	u8	val;
 };
 
+/*
+ *	Sysctls which determine global values for feature negotiation
+ */
+extern unsigned long sysctl_dccp_feat_sequence_window;
+extern int sysctl_dccp_feat_ack_ratio;
+extern int sysctl_dccp_feat_rx_ccid;
+extern int sysctl_dccp_feat_tx_ccid;
+extern int sysctl_dccp_feat_send_ndp_count;
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern const char *dccp_feat_typename(const u8 type);
 extern const char *dccp_feat_name(const u8 feat);
@@ -102,6 +111,7 @@ static inline void dccp_feat_debug(const
 #endif /* CONFIG_IP_DCCP_DEBUG */
 
 extern int  dccp_feat_init(struct sock *sk);
+extern void dccp_feat_initialise_sysctls(void);
 extern int  dccp_feat_register_change(struct sock *sk, u8 feat,
 				      u8 is_local, u8 *val, u8 len);
 extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -26,6 +26,12 @@
 #include "ccid.h"
 #include "feat.h"
 
+/* sysctls related to initialisation of option values */
+unsigned long	sysctl_dccp_feat_sequence_window;
+int		sysctl_dccp_feat_rx_ccid,
+		sysctl_dccp_feat_tx_ccid,
+		sysctl_dccp_feat_ack_ratio;
+
 /* Feature activation handlers */
 extern int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx);
 extern int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx);
@@ -1022,6 +1028,18 @@ int dccp_feat_parse_options(struct sock 
 	return 0;	/* ignore FN options in all other states */
 }
 
+/* initialise sysctls with default values from the table */
+void __init dccp_feat_initialise_sysctls(void)
+{
+#define DCCP_FEAT_SYSCTL_INIT(var, feat) \
+	sysctl_dccp_feat_ ##var = dccp_feat_default_value(DCCPF_ ##feat)
+
+	DCCP_FEAT_SYSCTL_INIT(sequence_window, SEQUENCE_WINDOW);
+	DCCP_FEAT_SYSCTL_INIT(rx_ccid, CCID);
+	DCCP_FEAT_SYSCTL_INIT(tx_ccid, CCID);
+	DCCP_FEAT_SYSCTL_INIT(ack_ratio, ACK_RATIO);
+}
+
 /**
  * dccp_feat_init  -  Seed feature negotiation with host-specific defaults
  * This initialises global defaults, depending on the value of the sysctls.
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -18,62 +18,81 @@
 #error This file should not be compiled without CONFIG_SYSCTL defined
 #endif
 
+static int		zero     = 0,
+			u8_max   = 0xFF,
+			u16_max  = 0xFFFF;
+static unsigned long	seqw_min = 32;
+
 static struct ctl_table dccp_default_table[] = {
 	{
 		.procname	= "seq_window",
 		.data		= &sysctl_dccp_feat_sequence_window,
 		.maxlen		= sizeof(sysctl_dccp_feat_sequence_window),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1		= &seqw_min,		/* RFC 4340, 7.5.2 */
 	},
 	{
 		.procname	= "rx_ccid",
 		.data		= &sysctl_dccp_feat_rx_ccid,
 		.maxlen		= sizeof(sysctl_dccp_feat_rx_ccid),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &u8_max,		/* RFC 4340, 10. */
 	},
 	{
 		.procname	= "tx_ccid",
 		.data		= &sysctl_dccp_feat_tx_ccid,
 		.maxlen		= sizeof(sysctl_dccp_feat_tx_ccid),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &u8_max,		/* RFC 4340, 10. */
 	},
 	{
 		.procname	= "ack_ratio",
 		.data		= &sysctl_dccp_feat_ack_ratio,
 		.maxlen		= sizeof(sysctl_dccp_feat_ack_ratio),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &u16_max,		/* RFC 4340, 11.3 */
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
@@ -120,6 +139,7 @@ static struct ctl_table_header *dccp_tab
 
 int __init dccp_sysctl_init(void)
 {
+	dccp_feat_initialise_sysctls();
 	dccp_table_header = register_sysctl_table(dccp_root_table);
 
 	return dccp_table_header != NULL ? 0 : -ENOMEM;
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -23,11 +23,6 @@
 #include "dccp.h"
 #include "feat.h"
 
-int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
-int sysctl_dccp_feat_rx_ccid	      = DCCPF_INITIAL_CCID;
-int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
-int sysctl_dccp_feat_ack_ratio	      = DCCPF_INITIAL_ACK_RATIO;
-
 u64 dccp_decode_value_var(const u8 *bf, const u8 len)
 {
 	u64 value = 0;
