From: <Markus.Amend@telekom.de>
Date: Tue, 30 Apr 2019 16:11:07 +0000
Subject: [PATCH v3] net: dccp: Checksum verification enhancement
Message-Id: <FRAPR01MB11707401056D4D6C95D8C615FA3A0@FRAPR01MB1170.DEUPRD01.PROD.OUTLOOK.DE>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The current patch modifies the checksum verification of a received DCCP
packet, by adding the function __skb_checksum_validate into the
dccp_vX_rcv routine. The purpose of the modification is to allow the
verification of the skb->ip_summed flags during the checksum validation
process (for checksum offload purposes). As __skb_checksum_validate
covers the functionalities of skb_checksum and dccp_vX_csum_finish they
are needless and therefore removed.

Signed-off-by: Nathalie Romo Moreno <natha.ro.moreno@gmail.com>
Signed-off-by: Markus Amend <markus.amend@telekom.de>
---
 net/dccp/ipv4.c | 6 ++----
 net/dccp/ipv6.c | 6 +++---
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 26a21d97b6b0..ca4eb93e4663 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -762,9 +762,6 @@ int dccp_invalid_packet(struct sk_buff *skb)
 		return 1;
 	}
 
-	/* If header checksum is incorrect, drop packet and return.
-	 * (This step is completed in the AF-dependent functions.) */
-	skb->csum = skb_checksum(skb, 0, cscov, 0);
 
 	return 0;
 }
@@ -786,7 +783,8 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 
 	iph = ip_hdr(skb);
 	/* Step 1: If header checksum is incorrect, drop packet and return */
-	if (dccp_v4_csum_finish(skb, iph->saddr, iph->daddr)) {
+	if (__skb_checksum_validate(skb, IPPROTO_DCCP,
+				    true, false, 0, inet_compute_pseudo)) {
 		DCCP_WARN("dropped packet with invalid checksum\n");
 		goto discard_it;
 	}
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index d5740bad5b18..22df24fecfe7 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -694,9 +694,9 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 	if (dccp_invalid_packet(skb))
 		goto discard_it;
 
-	/* Step 1: If header checksum is incorrect, drop packet and return. */
-	if (dccp_v6_csum_finish(skb, &ipv6_hdr(skb)->saddr,
-				     &ipv6_hdr(skb)->daddr)) {
+	/* Step 1: If header checksum is incorrect, drop packet and return */
+	if (__skb_checksum_validate(skb, IPPROTO_DCCP,
+				    true, false, 0, ip6_compute_pseudo)) {
 		DCCP_WARN("dropped packet with invalid checksum\n");
 		goto discard_it;
 	}
-- 
2.20.1
