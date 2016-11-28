From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2016 14:26:49 +0000
Subject: [PATCH net] net/dccp: fix use-after-free in dccp_invalid_packet
Message-Id: <1480343209.18162.50.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

pskb_may_pull() can reallocate skb->head, we need to reload dh pointer
in dccp_invalid_packet() or risk use after free.

Bug found by Andrey Konovalov using syzkaller.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/dccp/ipv4.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index b567c8725aea..edbe59d203ef 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -700,6 +700,7 @@ int dccp_invalid_packet(struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh;
 	unsigned int cscov;
+	u8 dccph_doff;
 
 	if (skb->pkt_type != PACKET_HOST)
 		return 1;
@@ -721,18 +722,19 @@ int dccp_invalid_packet(struct sk_buff *skb)
 	/*
 	 * If P.Data Offset is too small for packet type, drop packet and return
 	 */
-	if (dh->dccph_doff < dccp_hdr_len(skb) / sizeof(u32)) {
-		DCCP_WARN("P.Data Offset(%u) too small\n", dh->dccph_doff);
+	dccph_doff = dh->dccph_doff;
+	if (dccph_doff < dccp_hdr_len(skb) / sizeof(u32)) {
+		DCCP_WARN("P.Data Offset(%u) too small\n", dccph_doff);
 		return 1;
 	}
 	/*
 	 * If P.Data Offset is too too large for packet, drop packet and return
 	 */
-	if (!pskb_may_pull(skb, dh->dccph_doff * sizeof(u32))) {
-		DCCP_WARN("P.Data Offset(%u) too large\n", dh->dccph_doff);
+	if (!pskb_may_pull(skb, dccph_doff * sizeof(u32))) {
+		DCCP_WARN("P.Data Offset(%u) too large\n", dccph_doff);
 		return 1;
 	}
-
+	dh = dccp_hdr(skb);
 	/*
 	 * If P.type is not Data, Ack, or DataAck and P.X = 0 (the packet
 	 * has short sequence numbers), drop packet and return


