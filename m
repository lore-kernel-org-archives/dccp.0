From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Oct 2006 15:26:54 +0000
Subject: [Patch 1/3]:  dccp: Oops in DCCPv6
Message-Id: <200610111626.54149@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I think I got the cause for the Oops observed in 
http://www.mail-archive.com/dccp@vger.kernel.org/msg00578.html

The problem is always with applications listening on PF_INET6
sockets. Apart from the mentioned oops, I observed another one one,
triggered at irregular intervals via timer interrupt:

    run_timer_softirq -> dccp_keepalive_timer 
                      -> inet_csk_reqsk_queue_prune
                      -> reqsk_free
                      -> dccp_v6_reqsk_destructor

The latter function is the problem and is also the last function to be called
in said kernel panic. 

In any case, there is a real problem with allocating the right request_sock
which is what this patch tackles. 

It fixes the following problem:
 - application listens on PF_INET6
 - DCCPv4 packet comes in, is handed over to dccp_v4_do_rcv, from there
   to dccp_v4_conn_request

Now: socket is PF_INET6, packet is IPv4. The following code then furnishes
the connection with IPv6 - request_sock operations:
 
   req = reqsk_alloc(sk->sk_prot->rsk_prot);

The first problem is that all further incoming packets will get a Reset since
the connection can not be looked up. 

The second problem is worse:
 --> reqsk_alloc is called instead of inet6_reqsk_alloc
 --> consequently inet6_rsk_offset is never set (dangling pointer)
 --> the request_sock_ops are nevertheless still dccp6_request_ops
 --> destructor is called via reqsk_free
 --> dccp_v6_reqsk_destructor tries to free random memory location (inet6_rsk_offset not set)
 --> panic

I have tested this for a while, DCCP sockets are now handled correctly in all three scenarios
(v4/v6 only/v4-mapped). 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 ipv4.c |    2 +-
 ipv6.c |    4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7e746c4..d27e208 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -489,7 +489,7 @@ int dccp_v4_conn_request(struct sock *sk
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = reqsk_alloc(sk->sk_prot->rsk_prot);
+	req = reqsk_alloc(&dccp_request_sock_ops);
 	if (req = NULL)
 		goto drop;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 7171a78..91e7b12 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -672,7 +672,6 @@ static struct sock *dccp_v6_hnd_req(stru
 
 static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct inet_request_sock *ireq;
 	struct dccp_sock dp;
 	struct request_sock *req;
 	struct dccp_request_sock *dreq;
@@ -701,7 +700,7 @@ static int dccp_v6_conn_request(struct s
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = inet6_reqsk_alloc(sk->sk_prot->rsk_prot);
+	req = inet6_reqsk_alloc(&dccp6_request_sock_ops);
 	if (req = NULL)
 		goto drop;
 
@@ -713,7 +712,6 @@ static int dccp_v6_conn_request(struct s
 		goto drop_and_free;
 
 	ireq6 = inet6_rsk(req);
-	ireq = inet_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &skb->nh.ipv6h->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &skb->nh.ipv6h->daddr);
 	req->rcv_wnd	= dccp_feat_default_sequence_window;
