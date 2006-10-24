From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 13:59:20 +0000
Subject: [PATCH 3/17] [DCCPv6]: FIXME for missing IPV6_PKTOPTIONS handling
Message-Id: <200610241459.20543@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCPv6]: Add a FIXME for missing IPV6_PKTOPTIONS

This refers to the possible memory leak pointed out in
http://www.mail-archive.com/dccp@vger.kernel.org/msg00574.html,
fixed by David Miller in 
http://www.mail-archive.com/netdev@vger.kernel.org/msg24881.html

and adds a FIXME to point out where code is missing.

Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/ipv6.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index eb0ff7a..64bf9e2 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -990,13 +990,17 @@ static int dccp_v6_do_rcv(struct sock *s
 	                                       --ANK (980728)
 	 */
 	if (np->rxopt.all)
+	/*
+	 * FIXME: Add handling of IPV6_PKTOPTIONS skb. See the comments below
+	 *        (wrt ipv6_pktopions) and net/ipv6/tcp_ipv6.c for an example.
+	 */
 		opt_skb = skb_clone(skb, GFP_ATOMIC);
 
 	if (sk->sk_state = DCCP_OPEN) { /* Fast path */
 		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
 			goto reset;
 		if (opt_skb) {
-			/* This is where we would goto ipv6_pktoptions. */
+			/* XXX This is where we would goto ipv6_pktoptions. */
 			__kfree_skb(opt_skb);
 		}
 		return 0;
@@ -1024,7 +1028,7 @@ static int dccp_v6_do_rcv(struct sock *s
 	if (dccp_rcv_state_process(sk, skb, dccp_hdr(skb), skb->len))
 		goto reset;
 	if (opt_skb) {
-		/* This is where we would goto ipv6_pktoptions. */
+		/* XXX This is where we would goto ipv6_pktoptions. */
 		__kfree_skb(opt_skb);
 	}
 	return 0;

