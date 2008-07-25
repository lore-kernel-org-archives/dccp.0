From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 14:29:57 +0000
Subject: [PATCH 5/7] dccp: Pulling 12 bytes is necessary but not sufficient
Message-Id: <20080725142957.GB7422@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch fixes a bug in testing the minimum header length and encapsulates
the fixed test into a routine for further use.

In TCP, it is safe to use pskb_may_pull(skb, sizeof(struct tcphdr)) and then
assume that all header fields can be accessed.

DCCP however has a dynamic header length:

 * the minimum header length is 12 bytes (required by Step 1 in RFC 4340, 8.5);
 * but if the `X' bit is set within this base header, then the minimum
   required length is 16 bytes (__dccp_basic_hdr_len() computes that);
 * so that accessing P.seqno in Step 6 of RFC 4340, 8.5 will fail.

Hence we need to first test whether 12 bytes are available, and only then can
dereference the X-bit to see if (likely) 4 more bytes need to be read.

Many thanks to David Miller who pointed this problem out.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   12 ++++++++++++
 net/dccp/ipv4.c      |    5 ++---
 2 files changed, 14 insertions(+), 3 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -302,6 +302,18 @@ static inline unsigned int dccp_basic_hdr_len(const struct sk_buff *skb)
 	return __dccp_basic_hdr_len(dh);
 }
 
+/*
+ * RFC 4340, 8.5. Step 1 says that 12 bytes is too short. However, to do Step 6
+ * we need at least __dccp_basic_hdr_len() (up to 16 bytes) to access P.seqno.
+ */
+static inline bool dccp_skb_too_short(struct sk_buff *skb, const u32 offset)
+{
+	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + offset);
+
+	return !(pskb_may_pull(skb, offset + sizeof(*dh)) &&
+		 pskb_may_pull(skb, offset + __dccp_basic_hdr_len(dh)));
+}
+
 static inline __u64 dccp_hdr_seq(const struct dccp_hdr *dh)
 {
 	__u64 seq_nr =  ntohs(dh->dccph_seq);
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -706,9 +706,8 @@ int dccp_invalid_packet(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		return 1;
 
-	/* If the packet is shorter than 12 bytes, drop packet and return */
-	if (!pskb_may_pull(skb, sizeof(struct dccp_hdr))) {
-		DCCP_WARN("pskb_may_pull failed\n");
+	if (dccp_skb_too_short(skb, 0)) {
+		DCCP_WARN("Packet too short (%u)\n", skb->len);
 		return 1;
 	}
 
