From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 26 Jul 2007 12:56:48 +0000
Subject: [PATCH 4/5]: Always support Ack Vectors
Message-Id: <200707261356.49095@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Always support Ack Vectors

This removes CONFIG_IP_DCCP_ACKVEC for reasons of inter-operability.

In RFC 4340 requires CCID2 as a kind of default (section 10):
 "A DCCP implementation intended for general use, such as an implementation 
  in a general-purpose operating system kernel, SHOULD implement at least CCID 2.2

RFC 4341, section 4 says that the use of "Ack Vector is MANDATORY on CCID 2 half-connections".  
(This was so far ensured via Kconfig option). New connections start with CCID 2 for both 
endpoints [RFC 4340, sec. 10]

Taken together this indicates that Ack Vectors should not be disabled in the build process.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/Kconfig       |    3 ---
 net/dccp/Makefile      |    4 +---
 net/dccp/ackvec.h      |   49 -------------------------------------------------
 net/dccp/ccids/Kconfig |    1 -
 net/dccp/dccp.h        |    2 --
 5 files changed, 1 insertion(+), 58 deletions(-)

--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,7 +1,7 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
 dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o \
-	  sysctl.o
+	  sysctl.o ackvec.o
 
 dccp_ipv4-y := ipv4.o
 
@@ -9,8 +9,6 @@ dccp_ipv4-y := ipv4.o
 obj-$(subst y,$(CONFIG_IP_DCCP),$(CONFIG_IPV6)) += dccp_ipv6.o
 dccp_ipv6-y := ipv6.o
 
-dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.o
-
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o
 obj-$(CONFIG_NET_DCCPPROBE) += dccp_probe.o
 
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -85,7 +85,6 @@ struct dccp_ackvec_record {
 struct sock;
 struct sk_buff;
 
-#ifdef CONFIG_IP_DCCP_ACKVEC
 extern int dccp_ackvec_init(void);
 extern void dccp_ackvec_exit(void);
 
@@ -107,52 +106,4 @@ static inline int dccp_ackvec_pending(co
 {
 	return av->dccpav_vec_len;
 }
-#else /* CONFIG_IP_DCCP_ACKVEC */
-static inline int dccp_ackvec_init(void)
-{
-	return 0;
-}
-
-static inline void dccp_ackvec_exit(void)
-{
-}
-
-static inline struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
-{
-	return NULL;
-}
-
-static inline void dccp_ackvec_free(struct dccp_ackvec *av)
-{
-}
-
-static inline int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
-				  const u64 ackno, const u8 state)
-{
-	return -1;
-}
-
-static inline void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av,
-					       struct sock *sk, const u64 ackno)
-{
-}
-
-static inline int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-				    const u64 *ackno, const u8 opt,
-				    const u8 *value, const u8 len)
-{
-	return -1;
-}
-
-static inline int dccp_insert_option_ackvec(const struct sock *sk,
-					    const struct sk_buff *skb)
-{
-	return -1;
-}
-
-static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
-{
-	return 0;
-}
-#endif /* CONFIG_IP_DCCP_ACKVEC */
 #endif /* _ACKVEC_H */
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -400,10 +400,8 @@ static inline int dccp_ack_pending(const
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
 	return dp->dccps_timestamp_echo != 0 ||
-#ifdef CONFIG_IP_DCCP_ACKVEC
 	       (dccp_msk(sk)->dccpms_send_ack_vector &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
-#endif
 	       inet_csk_ack_scheduled(sk);
 }
 
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -5,7 +5,6 @@ config IP_DCCP_CCID2
 	tristate "CCID2 (TCP-Like) (EXPERIMENTAL)"
 	depends on IP_DCCP
 	def_tristate IP_DCCP
-	select IP_DCCP_ACKVEC
 	---help---
 	  CCID 2, TCP-like Congestion Control, denotes Additive Increase,
 	  Multiplicative Decrease (AIMD) congestion control with behavior
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -24,9 +24,6 @@ config INET_DCCP_DIAG
 	def_tristate y if (IP_DCCP = y && INET_DIAG = y)
 	def_tristate m
 
-config IP_DCCP_ACKVEC
-	bool
-
 source "net/dccp/ccids/Kconfig"
 
 menu "DCCP Kernel Hacking"
