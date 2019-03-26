From: <Markus.Amend@telekom.de>
Date: Tue, 26 Mar 2019 08:54:41 +0000
Subject: [PATCH v2] net: dccp: Checksum verification enhancement
Message-Id: <FRAPR01MB117083E6F526BDCB88742713FA5F0@FRAPR01MB1170.DEUPRD01.PROD.OUTLOOK.DE>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Modify checksum verification to allow the validation of skb->ip_summed, in case the checksum has already been verified in lower layers.

Signed-off-by: Nathalie Romo Moreno <natha.ro.moreno@gmail.com>
Signed-off-by: Markus Amend <markus.amend@telekom.de>
---
 net/dccp/ipv4.c | 8 +++++---
 net/dccp/ipv6.c | 4 ++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c index 26a21d97b6b0..7e56327e385a 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -763,8 +763,9 @@ int dccp_invalid_packet(struct sk_buff *skb)
 	}
 
 	/* If header checksum is incorrect, drop packet and return.
-	 * (This step is completed in the AF-dependent functions.) */
-	skb->csum = skb_checksum(skb, 0, cscov, 0);
+	 * (This step is completed in the AF-dependent functions.)
+	 * skb->csum = skb_checksum(skb, 0, cscov, 0);
+	 */
 
 	return 0;
 }
@@ -786,7 +787,8 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 
 	iph = ip_hdr(skb);
 	/* Step 1: If header checksum is incorrect, drop packet and return */
-	if (dccp_v4_csum_finish(skb, iph->saddr, iph->daddr)) {
+	if (__skb_checksum_validate(skb, IPPROTO_DCCP,
+				    true, false, 0, inet_compute_pseudo)) {
 		DCCP_WARN("dropped packet with invalid checksum\n");
 		goto discard_it;
 	}
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c index d5740bad5b18..60743c425ceb 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -695,8 +695,8 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 		goto discard_it;
 
 	/* Step 1: If header checksum is incorrect, drop packet and return. */
-	if (dccp_v6_csum_finish(skb, &ipv6_hdr(skb)->saddr,
-				     &ipv6_hdr(skb)->daddr)) {
+	if (__skb_checksum_validate(skb, IPPROTO_DCCP,
+				    true, false, 0, ip6_compute_pseudo)) {
 		DCCP_WARN("dropped packet with invalid checksum\n");
 		goto discard_it;
 	}
--
2.20.1
