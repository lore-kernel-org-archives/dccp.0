From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 18:40:39 +0000
Subject: [PATCH 7/8] [DCCP]: Sequence number wrap-around when sending reset
Message-Id: <20070926184039.GI10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This replaces normal addition with mod-48 addition so that sequence number
wraparound is respected.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ipv4.c |    2 +-
 net/dccp/ipv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 2c62828..58a79c2 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -552,7 +552,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 
 	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
 	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-		dccp_set_seqno(&seqno, DCCP_SKB_CB(rxskb)->dccpd_ack_seq + 1);
+		seqno = ADD48(DCCP_SKB_CB(rxskb)->dccpd_ack_seq, 1);
 
 	dccp_hdr_set_seq(dh, seqno);
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index b158c66..d954e83 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -336,7 +336,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 
 	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
 	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-		dccp_set_seqno(&seqno, DCCP_SKB_CB(rxskb)->dccpd_ack_seq + 1);
+		seqno = ADD48(DCCP_SKB_CB(rxskb)->dccpd_ack_seq, 1);
 
 	dccp_hdr_set_seq(dh, seqno);
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
-- 
1.5.2.2

