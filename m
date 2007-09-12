From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Sep 2007 14:35:08 +0000
Subject: [PATCH 1/5]: Sequence number wrap-around when sending reset
Message-Id: <200709121535.08544@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Sequence number wrap-around when sending reset

This replaces normal addition with mod-48 addition so that
sequence number wraparound is respected.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c |    2 +-
 net/dccp/ipv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -554,7 +554,7 @@ static void dccp_v4_ctl_send_reset(struc
 
 	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
 	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-		dccp_set_seqno(&seqno, DCCP_SKB_CB(rxskb)->dccpd_ack_seq + 1);
+		seqno = ADD48(DCCP_SKB_CB(rxskb)->dccpd_ack_seq, 1);
 
 	dccp_hdr_set_seq(dh, seqno);
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -336,7 +336,7 @@ static void dccp_v6_ctl_send_reset(struc
 
 	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
 	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-		dccp_set_seqno(&seqno, DCCP_SKB_CB(rxskb)->dccpd_ack_seq + 1);
+		seqno = ADD48(DCCP_SKB_CB(rxskb)->dccpd_ack_seq, 1);
 
 	dccp_hdr_set_seq(dh, seqno);
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
