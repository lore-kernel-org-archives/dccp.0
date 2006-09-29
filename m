From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Fri, 29 Sep 2006 00:45:33 +0000
Subject: [PATCH] IPv6/DCCP: Fix memory leak in dccp_v6_do_rcv()
Message-Id: <200609290245.33618.jesper.juhl@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Coverity found what looks like a real leak in net/dccp/ipv6.c::dccp_v6_do_rcv()

We may leave via the return inside "if (sk->sk_state = DCCP_OPEN) {"
but at that point we may have allocated opt_skb, but we never free it
in that path before the return.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 net/dccp/ipv6.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-2.6.18-git10-orig/net/dccp/ipv6.c	2006-09-28 22:40:07.000000000 +0200
+++ linux-2.6.18-git10/net/dccp/ipv6.c	2006-09-29 02:35:15.000000000 +0200
@@ -997,6 +997,8 @@ static int dccp_v6_do_rcv(struct sock *s
 	if (sk->sk_state = DCCP_OPEN) { /* Fast path */
 		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
 			goto reset;
+		if (opt_skb)
+			__kfree_skb(opt_skb);
 		return 0;
 	}
 





PS. Please keep me on Cc:

-- 
Jesper Juhl <jesper.juhl@gmail.com>





