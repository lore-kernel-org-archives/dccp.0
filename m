From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 29 Sep 2006 10:02:18 +0000
Subject: [PATCH] IPv6/DCCP: Remove unused IPV6_PKTOPTIONS code
Message-Id: <200609291102.19243@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>  Coverity found what looks like a real leak in net/dccp/ipv6.c::dccp_v6_do_rcv()

|  otoh, it seems to me that opt_skb doesn't actually do anything and can be
|  removed?
This is right, there is no code referencing opt_skb: compare with net/ipv6/tcp_ipv6.c.
Until someone has time to add the missing DCCP-specific code, it does seem better
to replace the dead part with a FIXME. This is done by the patch below, applies to
davem-net2.6 and has been tested to compile.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
--
 ipv6.c |   23 ++---------------------
 1 file changed, 2 insertions(+), 21 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 7a47399..9d19344 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -956,8 +956,6 @@ out:
  */
 static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct sk_buff *opt_skb = NULL;
 
 	/* Imagine: socket is IPv6. IPv4 packet arrives,
 	   goes to IPv4 receive handler and backlogged.
@@ -978,21 +976,8 @@ static int dccp_v6_do_rcv(struct sock *s
 	 * called with bh processing disabled.
 	 */
 
-	/* Do Stevens' IPV6_PKTOPTIONS.
-
-	   Yes, guys, it is the only place in our code, where we
-	   may make it not affecting IPv4.
-	   The rest of code is protocol independent,
-	   and I do not like idea to uglify IPv4.
-
-	   Actually, all the idea behind IPV6_PKTOPTIONS
-	   looks not very well thought. For now we latch
-	   options, received in the last packet, enqueued
-	   by tcp. Feel free to propose better solution.
-	                                       --ANK (980728)
-	 */
-	if (np->rxopt.all)
-		opt_skb = skb_clone(skb, GFP_ATOMIC);
+	/* FIXME: Add handling of IPV6_PKTOPTIONS with appropriate freeing of 
+	 *        skb (see net/ipv6/tcp_ipv6.c for example)                   */
 
 	if (sk->sk_state = DCCP_OPEN) { /* Fast path */
 		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
@@ -1013,8 +998,6 @@ static int dccp_v6_do_rcv(struct sock *s
  		if (nsk != sk) {
 			if (dccp_child_process(sk, nsk, skb))
 				goto reset;
-			if (opt_skb != NULL)
-				__kfree_skb(opt_skb);
 			return 0;
 		}
 	}
@@ -1026,8 +1009,6 @@ static int dccp_v6_do_rcv(struct sock *s
 reset:
 	dccp_v6_ctl_send_reset(skb);
 discard:
-	if (opt_skb != NULL)
-		__kfree_skb(opt_skb);
 	kfree_skb(skb);
 	return 0;
 }


