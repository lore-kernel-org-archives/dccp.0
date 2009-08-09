From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:38 +0000
Subject: dccp-test-tree [PATCH 1/10]: Put the ECN bits into the dccp_skb_cb
Message-Id: <1249847327-6792-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds the two bits from the IPv4 TOS or IPv6 Traffic Class field into the
dccp_skb_cb.

To make the required room, dccp_opt_len is curtailed to 10 bits, since the
DCCP option length can not exceed 1020 < 2^10-1.

Further changes:
----------------
 * added code to copy the TOS/traffic class field contents,
 * supplied a utility function that checks for CE,
 * deleted duplicate inclusion of headers.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |   10 +++++++++-
 net/dccp/ipv4.c |    5 ++---
 net/dccp/ipv6.c |   15 ++++++++-------
 3 files changed, 19 insertions(+), 11 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -14,6 +14,7 @@
 
 #include <linux/dccp.h>
 #include <linux/ktime.h>
+#include <net/inet_ecn.h>
 #include <net/snmp.h>
 #include <net/sock.h>
 #include <net/tcp.h>
@@ -355,6 +356,7 @@ static inline int dccp_bad_service_code(const struct sock *sk,
  * dccp_skb_cb  -  DCCP per-packet control information
  * @dccpd_type: one of %dccp_pkt_type (or unknown)
  * @dccpd_ccval: CCVal field (5.1), see e.g. RFC 4342, 8.1
+ * @dccpd_ecn: ECN bits read from the IPv4 TOS / IPv6 Traffic Class field
  * @dccpd_reset_code: one of %dccp_reset_codes
  * @dccpd_reset_data: Data1..3 fields (depend on @dccpd_reset_code)
  * @dccpd_opt_len: total length of all options (5.8) in the packet
@@ -371,15 +373,21 @@ struct dccp_skb_cb {
 	} header;
 	__u8  dccpd_type:4;
 	__u8  dccpd_ccval:4;
+	__u8  dccpd_ecn:2;
 	__u8  dccpd_reset_code,
 	      dccpd_reset_data[3];
-	__u16 dccpd_opt_len;
+	__u16 dccpd_opt_len:10;
 	__u64 dccpd_seq;
 	__u64 dccpd_ack_seq;
 };
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
 
+static inline bool dccp_skb_is_ecn_ce(const struct sk_buff *skb)
+{
+	return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) = INET_ECN_CE;
+}
+
 /* RFC 4340, sec. 7.7 */
 static inline int dccp_non_data_packet(const struct sk_buff *skb)
 {
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -10,16 +10,13 @@
  *	2 of the License, or (at your option) any later version.
  */
 
-#include <linux/dccp.h>
 #include <linux/icmp.h>
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/random.h>
 
 #include <net/icmp.h>
 #include <net/inet_common.h>
 #include <net/inet_hashtables.h>
-#include <net/inet_sock.h>
 #include <net/protocol.h>
 #include <net/sock.h>
 #include <net/timewait_sock.h>
@@ -783,6 +780,8 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 		goto discard_it;
 
 	iph = ip_hdr(skb);
+	DCCP_SKB_CB(skb)->dccpd_ecn = iph->tos & INET_ECN_MASK;
+
 	/* Step 1: If header checksum is incorrect, drop packet and return */
 	if (dccp_v4_csum_finish(skb, iph->saddr, iph->daddr)) {
 		DCCP_WARN("dropped packet with invalid checksum\n");
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -19,7 +19,6 @@
 #include <net/addrconf.h>
 #include <net/inet_common.h>
 #include <net/inet_hashtables.h>
-#include <net/inet_sock.h>
 #include <net/inet6_connection_sock.h>
 #include <net/inet6_hashtables.h>
 #include <net/ip6_route.h>
@@ -783,6 +782,7 @@ discard:
 
 static int dccp_v6_rcv(struct sk_buff *skb)
 {
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	const struct dccp_hdr *dh;
 	struct sock *sk;
 	int min_cov;
@@ -792,6 +792,8 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 	if (dccp_invalid_packet(skb))
 		goto discard_it;
 
+	dcb->dccpd_ecn = ipv6_get_dsfield(ipv6_hdr(skb)) & INET_ECN_MASK;
+
 	/* Step 1: If header checksum is incorrect, drop packet and return. */
 	if (dccp_v6_csum_finish(skb, &ipv6_hdr(skb)->saddr,
 				     &ipv6_hdr(skb)->daddr)) {
@@ -801,13 +803,13 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 
 	dh = dccp_hdr(skb);
 
-	DCCP_SKB_CB(skb)->dccpd_seq  = dccp_hdr_seq(dh);
-	DCCP_SKB_CB(skb)->dccpd_type = dh->dccph_type;
+	dcb->dccpd_seq  = dccp_hdr_seq(dh);
+	dcb->dccpd_type = dh->dccph_type;
 
 	if (dccp_packet_without_ack(skb))
-		DCCP_SKB_CB(skb)->dccpd_ack_seq = DCCP_PKT_WITHOUT_ACK_SEQ;
+		dcb->dccpd_ack_seq = DCCP_PKT_WITHOUT_ACK_SEQ;
 	else
-		DCCP_SKB_CB(skb)->dccpd_ack_seq = dccp_hdr_ack_seq(skb);
+		dcb->dccpd_ack_seq = dccp_hdr_ack_seq(skb);
 
 	/* Step 2:
 	 *	Look up flow ID in table and get corresponding socket */
@@ -863,8 +865,7 @@ no_dccp_socket:
 	 *		Drop packet and return
 	 */
 	if (dh->dccph_type != DCCP_PKT_RESET) {
-		DCCP_SKB_CB(skb)->dccpd_reset_code -					DCCP_RESET_CODE_NO_CONNECTION;
+		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
 		dccp_v6_ctl_send_reset(sk, skb);
 	}
 
-- 
1.6.0.rc2

