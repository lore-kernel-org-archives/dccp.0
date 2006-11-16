From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 16 Nov 2006 16:33:26 +0000
Subject: [PATCH 2/3][NET]: Conditionally use bh_lock_sock_nested in sk_receive_skb
Message-Id: <20061116163326.GD5195@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Spotted by Ian McDonald, tentatively fixed by Gerrit Renker:

http://www.mail-archive.com/dccp%40vger.kernel.org/msg00599.html

Rewritten not to unroll sk_receive_skb, in the common case, i.e. no lock
debugging, its optimized away.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 drivers/net/pppoe.c    |    2 +-
 include/net/sock.h     |    3 ++-
 net/core/sock.c        |    7 +++++--
 net/dccp/ipv4.c        |    2 +-
 net/dccp/ipv6.c        |    2 +-
 net/decnet/dn_nsp_in.c |    2 +-
 6 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 0adee73..315d5c3 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -393,7 +393,7 @@ static int pppoe_rcv(struct sk_buff *skb
 
 	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source);
 	if (po != NULL)
-		return sk_receive_skb(sk_pppox(po), skb);
+		return sk_receive_skb(sk_pppox(po), skb, 0);
 drop:
 	kfree_skb(skb);
 out:
diff --git a/include/net/sock.h b/include/net/sock.h
index c842c52..13ef9e6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -949,7 +949,8 @@ static inline void sock_put(struct sock 
 		sk_free(sk);
 }
 
-extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb);
+extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
+			  const int nested);
 
 /* Detach socket from process context.
  * Announce socket dead, detach it from wait queue and inode.
diff --git a/net/core/sock.c b/net/core/sock.c
index 32ff1c5..ab8fafa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -270,7 +270,7 @@ out:
 }
 EXPORT_SYMBOL(sock_queue_rcv_skb);
 
-int sk_receive_skb(struct sock *sk, struct sk_buff *skb)
+int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
 {
 	int rc = NET_RX_SUCCESS;
 
@@ -279,7 +279,10 @@ int sk_receive_skb(struct sock *sk, stru
 
 	skb->dev = NULL;
 
-	bh_lock_sock(sk);
+	if (nested)
+		bh_lock_sock_nested(sk);
+	else
+		bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk)) {
 		/*
 		 * trylock + unlock semantics:
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a20eb71..7114bef 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -899,7 +899,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 		goto discard_and_relse;
 	nf_reset(skb);
 
-	return sk_receive_skb(sk, skb);
+	return sk_receive_skb(sk, skb, 1);
 
 no_dccp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3ab7e49..efd0655 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -888,7 +888,7 @@ static int dccp_v6_rcv(struct sk_buff **
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
-	return sk_receive_skb(sk, skb) ? -1 : 0;
+	return sk_receive_skb(sk, skb, 1) ? -1 : 0;
 
 no_dccp_socket:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 7683d4f..39a6cf7 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -804,7 +804,7 @@ got_it:
 				goto free_out;
 		}
 
-		return sk_receive_skb(sk, skb);
+		return sk_receive_skb(sk, skb, 0);
 	}
 
 	return dn_nsp_no_socket(skb, reason);
-- 
1.4.2.1.g3d5c

