From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 29 Sep 2007 16:42:29 +0000
Subject: [PATCH 1/3]: Retrieve packet sequence number for error reporting
Message-Id: <200709291742.29403@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Retrieve packet sequence number for error reporting

This fixes a problem when analysing erroneous packets in dccp_v{4,6}_err:
 * dccp_hdr_seq currently takes an skb
 * however, the transport headers in the skb are shifted, due to the
   preceding ICMPv4/v6 header.
Fixed for v4 and v6 by changing dccp_hdr_seq to take a struct dccp_hdr as
argument. Verified that the correct sequence number is now reported in the
error handler.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   10 ++++------
 net/dccp/ipv4.c      |    4 ++--
 net/dccp/ipv6.c      |    4 ++--
 3 files changed, 8 insertions(+), 10 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -271,10 +271,9 @@ static inline struct dccp_hdr *dccp_zero
 	return memset(skb_transport_header(skb), 0, headlen);
 }
 
-static inline struct dccp_hdr_ext *dccp_hdrx(const struct sk_buff *skb)
+static inline struct dccp_hdr_ext *dccp_hdrx(const struct dccp_hdr *dh)
 {
-	return (struct dccp_hdr_ext *)(skb_transport_header(skb) +
-				       sizeof(struct dccp_hdr));
+	return (struct dccp_hdr_ext *)((unsigned char *)dh + sizeof(*dh));
 }
 
 static inline unsigned int __dccp_basic_hdr_len(const struct dccp_hdr *dh)
@@ -288,13 +287,12 @@ static inline unsigned int dccp_basic_hd
 	return __dccp_basic_hdr_len(dh);
 }
 
-static inline __u64 dccp_hdr_seq(const struct sk_buff *skb)
+static inline __u64 dccp_hdr_seq(const struct dccp_hdr *dh)
 {
-	const struct dccp_hdr *dh = dccp_hdr(skb);
 	__u64 seq_nr =  ntohs(dh->dccph_seq);
 
 	if (dh->dccph_x != 0)
-		seq_nr = (seq_nr << 32) + ntohl(dccp_hdrx(skb)->dccph_seq_low);
+		seq_nr = (seq_nr << 32) + ntohl(dccp_hdrx(dh)->dccph_seq_low);
 	else
 		seq_nr += (u32)dh->dccph_seq2 << 16;
 
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -241,7 +241,7 @@ static void dccp_v4_err(struct sk_buff *
 		goto out;
 
 	dp = dccp_sk(sk);
-	seq = dccp_hdr_seq(skb);
+	seq = dccp_hdr_seq(dh);
 	if (sk->sk_state != DCCP_LISTEN &&
 	    !between48(seq, dp->dccps_swl, dp->dccps_swh)) {
 		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
@@ -828,7 +828,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 
 	dh = dccp_hdr(skb);
 
-	DCCP_SKB_CB(skb)->dccpd_seq  = dccp_hdr_seq(skb);
+	DCCP_SKB_CB(skb)->dccpd_seq  = dccp_hdr_seq(dh);
 	DCCP_SKB_CB(skb)->dccpd_type = dh->dccph_type;
 
 	dccp_pr_debug("%8.8s "
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -173,7 +173,7 @@ static void dccp_v6_err(struct sk_buff *
 
 	icmpv6_err_convert(type, code, &err);
 
-	seq = DCCP_SKB_CB(skb)->dccpd_seq;
+	seq = dccp_hdr_seq(dh);
 	/* Might be for an request_sock */
 	switch (sk->sk_state) {
 		struct request_sock *req, **prev;
@@ -816,7 +816,7 @@ static int dccp_v6_rcv(struct sk_buff **
 
 	dh = dccp_hdr(skb);
 
-	DCCP_SKB_CB(skb)->dccpd_seq  = dccp_hdr_seq(skb);
+	DCCP_SKB_CB(skb)->dccpd_seq  = dccp_hdr_seq(dh);
 	DCCP_SKB_CB(skb)->dccpd_type = dh->dccph_type;
 
 	if (dccp_packet_without_ack(skb))
