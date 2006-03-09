From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 09 Mar 2006 03:08:09 +0000
Subject: [PATCH 3/5] [DCCP]: ditch dccp_v[46]_ctl_send_ack
Message-Id: <11418736892679-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Merging it with its only user: dccp_v[46]_reqsk_send_ack.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ipv4.c |    9 ++-------
 net/dccp/ipv6.c |    9 ++-------
 2 files changed, 4 insertions(+), 14 deletions(-)

c4a14e8cbc06bc6733b5976a800cd1b669010bb7
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 64b7f8b..80d450b 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -197,7 +197,8 @@ static inline void dccp_do_pmtu_discover
 	} /* else let the usual retransmit timer handle it */
 }
 
-static void dccp_v4_ctl_send_ack(struct sk_buff *rxskb)
+static void dccp_v4_reqsk_send_ack(struct sk_buff *rxskb,
+				   struct request_sock *req)
 {
 	int err;
 	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
@@ -245,12 +246,6 @@ static void dccp_v4_ctl_send_ack(struct 
 	}
 }
 
-static void dccp_v4_reqsk_send_ack(struct sk_buff *skb,
-				   struct request_sock *req)
-{
-	dccp_v4_ctl_send_ack(skb);
-}
-
 static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
 				 struct dst_entry *dst)
 {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 0f328c7..7c8233f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -580,7 +580,8 @@ static void dccp_v6_ctl_send_reset(struc
 	kfree_skb(skb);
 }
 
-static void dccp_v6_ctl_send_ack(struct sk_buff *rxskb)
+static void dccp_v6_reqsk_send_ack(struct sk_buff *rxskb,
+				   struct request_sock *req)
 {
 	struct flowi fl;
 	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
@@ -633,12 +634,6 @@ static void dccp_v6_ctl_send_ack(struct 
 	kfree_skb(skb);
 }
 
-static void dccp_v6_reqsk_send_ack(struct sk_buff *skb,
-				   struct request_sock *req)
-{
-	dccp_v6_ctl_send_ack(skb);
-}
-
 static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
-- 
1.2.2.gd27d


