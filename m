From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 24 Jul 2008 08:49:47 +0000
Subject: [PATCH 3/4] DCCP: Fix to check missing sequence number for ICMP message
Message-Id: <4888422B.4010607@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The min length of dccp packet is 12, and if we want check the sequence 
number, the length of dccp packet must not less than 
__dccp_basic_hdr_len(dh). If the length of dccp packet is less than this 
value, check for sequence number will get unpredictable result.

This patch fix the problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

diff -Nurp a/net/dccp/ipv4.c b/net/dccp/ipv4.c
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -196,8 +196,8 @@ static inline void dccp_do_pmtu_discovery(struct sock *sk,
 static void dccp_v4_err(struct sk_buff *skb, u32 info)
 {
 	const struct iphdr *iph = (struct iphdr *)skb->data;
-	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data +
-							(iph->ihl << 2));
+	const int ihlen = iph->ihl * 4;
+	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + ihlen);
 	struct dccp_sock *dp;
 	struct inet_sock *inet;
 	const int type = icmp_hdr(skb)->type;
@@ -206,7 +206,8 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	__u64 seq;
 	int err;
 
-	if (skb->len < (iph->ihl << 2) + 8) {
+	if (skb->len < ihlen + 12 || 
+	    skb->len < ihlen + __dccp_basic_hdr_len(dh)) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
 		return;
 	}

