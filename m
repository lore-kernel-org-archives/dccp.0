From: Ian McDonald <imcdnzl@gmail.com>
Date: Tue, 20 Dec 2005 23:07:30 +0000
Subject: [PATCH] DCCP: Typo
Message-Id: <cbec11ac0512201507p168d332bl8e23a2ade30935d0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Please apply to net-2.6 for 2.6.15 tree.

I hope to actually change this behaviour shortly but this will help
anybody grepping code at present.

Signed-off-by: Ian McDonald <imcdnzl@gmail.com>
---
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ca03521..656e13e 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1251,7 +1251,7 @@ static int dccp_v4_destroy_sock(struct s
 	struct dccp_sock *dp = dccp_sk(sk);

 	/*
-	 * DCCP doesn't use sk_qrite_queue, just sk_send_head
+	 * DCCP doesn't use sk_write_queue, just sk_send_head
 	 * for retransmissions
 	 */
 	if (sk->sk_send_head != NULL) {
