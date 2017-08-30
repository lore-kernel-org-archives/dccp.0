From: Andrii Vladyka <tulup@mail.ru>
Date: Wed, 30 Aug 2017 06:04:35 +0000
Subject: [PATCH] net: dccp: Add handling of IPV6_PKTOPTIONS to dccp_v6_do_rcv()
Message-Id: <20170830090435.58406d1b@dev>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="MP_/yNhO8aNFP.q9o_53kE9NWpe"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--MP_/yNhO8aNFP.q9o_53kE9NWpe
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Add handling of IPV6_PKTOPTIONS to dccp_v6_do_rcv() in net/dccp/ipv6.c, similar
to the handling in net/ipv6/tcp_ipv6.c

Signed-off-by: Andrii Vladyka <tulup@mail.ru>
--MP_/yNhO8aNFP.q9o_53kE9NWpe
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=dccp.patch

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 1b58eac..fdff10b 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -16,6 +16,7 @@
 #include <linux/random.h>
 #include <linux/slab.h>
 #include <linux/xfrm.h>
+#include <linux/string.h>
 
 #include <net/addrconf.h>
 #include <net/inet_common.h>
@@ -30,6 +31,7 @@
 #include <net/ip6_checksum.h>
 #include <net/xfrm.h>
 #include <net/secure_seq.h>
+#include <net/sock.h>
 
 #include "dccp.h"
 #include "ipv6.h"
@@ -597,19 +599,13 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 					       --ANK (980728)
 	 */
 	if (np->rxopt.all)
-	/*
-	 * FIXME: Add handling of IPV6_PKTOPTIONS skb. See the comments below
-	 *        (wrt ipv6_pktopions) and net/ipv6/tcp_ipv6.c for an example.
-	 */
 		opt_skb = skb_clone(skb, GFP_ATOMIC);
 
 	if (sk->sk_state == DCCP_OPEN) { /* Fast path */
 		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
 			goto reset;
-		if (opt_skb) {
-			/* XXX This is where we would goto ipv6_pktoptions. */
-			__kfree_skb(opt_skb);
-		}
+		if (opt_skb)
+			goto ipv6_pktoptions;
 		return 0;
 	}
 
@@ -640,10 +636,8 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (dccp_rcv_state_process(sk, skb, dccp_hdr(skb), skb->len))
 		goto reset;
-	if (opt_skb) {
-		/* XXX This is where we would goto ipv6_pktoptions. */
-		__kfree_skb(opt_skb);
-	}
+	if (opt_skb) 
+		goto ipv6_pktoptions;
 	return 0;
 
 reset:
@@ -653,6 +647,36 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		__kfree_skb(opt_skb);
 	kfree_skb(skb);
 	return 0;
+	
+/*
+ * Handling IPV6_PKTOPTIONS skb the similar
+ * way it's done for net/ipv6/tcp_ipv6.c
+ */
+ipv6_pktoptions:
+	if (!((1 << sk->sk_state) & (DCCPF_CLOSED | DCCPF_LISTEN))) {
+		if (np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo)
+			np->mcast_oif = inet6_iif(opt_skb);
+		if (np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim)
+			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
+		if (np->rxopt.bits.rxflow || np->rxopt.bits.rxtclass)
+			np->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(opt_skb));
+		if (np->repflow)
+			np->flow_label = ip6_flowlabel(ipv6_hdr(opt_skb));
+		if (ipv6_opt_accepted(sk, opt_skb,
+				      &DCCP_SKB_CB(opt_skb)->header.h6)) {
+			skb_set_owner_r(opt_skb, sk);
+			memmove(IP6CB(opt_skb),
+				&DCCP_SKB_CB(opt_skb)->header.h6,
+			        sizeof(struct inet6_skb_parm));
+			opt_skb = xchg(&np->pktoptions, opt_skb);
+		} else {
+			__kfree_skb(opt_skb);
+			opt_skb = xchg(&np->pktoptions, NULL);
+		}
+	}
+
+	kfree_skb(opt_skb);
+	return 0;
 }
 
 static int dccp_v6_rcv(struct sk_buff *skb)

--MP_/yNhO8aNFP.q9o_53kE9NWpe--
