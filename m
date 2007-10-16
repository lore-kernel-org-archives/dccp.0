From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 16 Oct 2007 09:33:30 +0000
Subject: [patch 1/1][Resent]: Collect all scattered sysctl variables into sysctl.c
Message-Id: <200710161033.30981@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have pulled this out - this patch also applies to the latest netdev-2.6 with minor
offsets and is from http://www.mail-archive.com/dccp@vger.kernel.org/msg02081.html

---------------------> Patch <------------------------------------------------
[DCCP]: Collect all scattered sysctl variables into sysctl.c

This
 1. organizes the sysctl variables which are scattered over many DCCP source 
    files into sysctl.c - so that they can easier be found;
 2. wraps the compilation of the CONFIG_SYSCTL part into a conditional define 
    - if not enabled, then only the variables will be `compiled';
 3. shortens the definitions of init/exit dummy functions in the header file.

Hence mainly a tidy-up action. Code was found to compile and work
cleanly with various Kconfig configurations for SYSCTL.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/Makefile  |    5 ++---
 net/dccp/dccp.h    |   10 ++--------
 net/dccp/options.c |    7 -------
 net/dccp/proto.c   |    3 ---
 net/dccp/sysctl.c  |   20 +++++++++++++++++---
 net/dccp/timer.c   |    5 -----
 6 files changed, 21 insertions(+), 29 deletions(-)

--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -15,11 +15,6 @@
 
 #include "dccp.h"
 
-/* sysctl variables governing numbers of retransmission attempts */
-int  sysctl_dccp_request_retries	__read_mostly = TCP_SYN_RETRIES;
-int  sysctl_dccp_retries1		__read_mostly = TCP_RETR1;
-int  sysctl_dccp_retries2		__read_mostly = TCP_RETR2;
-
 static void dccp_write_err(struct sock *sk)
 {
 	sk->sk_err = sk->sk_err_soft ? : ETIMEDOUT;
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -14,13 +14,26 @@
 #include "dccp.h"
 #include "feat.h"
 
-#ifndef CONFIG_SYSCTL
-#error This file should not be compiled without CONFIG_SYSCTL defined
-#endif
+/* sysctls related to initialisation of option values */
+int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
+int sysctl_dccp_feat_rx_ccid	     = DCCPF_INITIAL_CCID;
+int sysctl_dccp_feat_tx_ccid	     = DCCPF_INITIAL_CCID;
+int sysctl_dccp_feat_ack_ratio	     = DCCPF_INITIAL_ACK_RATIO;
+int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
+int sysctl_dccp_feat_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
+
+/* the maximum queue length for tx in packets. 0 is no limit */
+int sysctl_dccp_tx_qlen		__read_mostly = 5;
+
+/* sysctl variables governing numbers of retransmission attempts */
+int sysctl_dccp_request_retries	__read_mostly = TCP_SYN_RETRIES;
+int sysctl_dccp_retries1	__read_mostly = TCP_RETR1;
+int sysctl_dccp_retries2	__read_mostly = TCP_RETR2;
 
 /* rate-limit for syncs in reply to sequence-invalid packets; RFC 4340, 7.5.4 */
 int sysctl_dccp_sync_ratelimit	__read_mostly = HZ / 8;
 
+#ifdef CONFIG_SYSCTL
 static struct ctl_table dccp_default_table[] = {
 	{
 		.procname	= "seq_window",
@@ -149,3 +162,4 @@ void dccp_sysctl_exit(void)
 		dccp_table_header = NULL;
 	}
 }
+#endif
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
-dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o
+dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o \
+	  sysctl.o
 
 dccp_ipv4-y := ipv4.o
 
@@ -13,8 +14,6 @@ dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o
 obj-$(CONFIG_NET_DCCPPROBE) += dccp_probe.o
 
-dccp-$(CONFIG_SYSCTL) += sysctl.o
-
 dccp_diag-y := diag.o
 dccp_probe-y := probe.o
 
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -430,14 +430,8 @@ extern int dccp_insert_option(struct soc
 extern int dccp_sysctl_init(void);
 extern void dccp_sysctl_exit(void);
 #else
-static inline int dccp_sysctl_init(void)
-{
-	return 0;
-}
-
-static inline void dccp_sysctl_exit(void)
-{
-}
+#define dccp_sysctl_init(void)	(0)
+#define dccp_sysctl_exit(void)
 #endif
 
 #endif /* _DCCP_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -23,13 +23,6 @@
 #include "dccp.h"
 #include "feat.h"
 
-int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
-int sysctl_dccp_feat_rx_ccid	      = DCCPF_INITIAL_CCID;
-int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
-int sysctl_dccp_feat_ack_ratio	      = DCCPF_INITIAL_ACK_RATIO;
-int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
-int sysctl_dccp_feat_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
-
 static u32 dccp_decode_value_var(const unsigned char *bf, const u8 len)
 {
 	u32 value = 0;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -52,9 +52,6 @@ struct inet_hashinfo __cacheline_aligned
 
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
-/* the maximum queue length for tx in packets. 0 is no limit */
-int sysctl_dccp_tx_qlen __read_mostly = 5;
-
 void dccp_set_state(struct sock *sk, const int state)
 {
 	const int oldstate = sk->sk_state;
