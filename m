From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Feb 2006 22:12:58 +0000
Subject: [PATCH 4/7] [DCCP]: Dont use dccp_v4_checksum in dccp_make_response
Message-Id: <11407327783238-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_make_response is shared by ipv4/6 and the ipv6 code was recalculating the
checksum, not good, so move the dccp_v4_checksum call to dccp_v4_send_response.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ipv4.c   |    3 +++
 net/dccp/output.c |    3 ---
 2 files changed, 3 insertions(+), 3 deletions(-)

e9ec1a839d3fe9f2ec5e864a094cf04b6c511c03
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 34d1b11..f087593 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -264,7 +264,10 @@ static int dccp_v4_send_response(struct 
 	skb = dccp_make_response(sk, dst, req);
 	if (skb != NULL) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
+		struct dccp_hdr *dh = dccp_hdr(skb);
 
+		dh->dccph_checksum = dccp_v4_checksum(skb, ireq->loc_addr,
+						      ireq->rmt_addr);
 		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 9922d26..6bd21e3 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -314,9 +314,6 @@ struct sk_buff *dccp_make_response(struc
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_isr);
 	dccp_hdr_response(skb)->dccph_resp_service = dreq->dreq_service;
 
-	dh->dccph_checksum = dccp_v4_checksum(skb, inet_rsk(req)->loc_addr,
-					      inet_rsk(req)->rmt_addr);
-
 	DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 	return skb;
 }
-- 
1.2.2.gd27d


