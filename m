From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 20 Nov 2006 20:51:31 +0000
Subject: [PATCH 1/9] [TCP]: Tidy up skb_entail
Message-Id: <20061120205131.GB5246@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Heck, it even saves us some few bytes:

[acme@newtoy net-2.6.20]$ codiff -f /tmp/tcp.o.before ../OUTPUT/qemu/net-2.6.20/net/ipv4/tcp.o
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/tcp.c:
  tcp_sendpage |   -7
  tcp_sendmsg  |   -5
 2 functions changed, 12 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ipv4/tcp.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 168f9de..a6b2289 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -463,11 +463,12 @@ static inline int forced_push(struct tcp
 static inline void skb_entail(struct sock *sk, struct tcp_sock *tp,
 			      struct sk_buff *skb)
 {
-	skb->csum = 0;
-	TCP_SKB_CB(skb)->seq = tp->write_seq;
-	TCP_SKB_CB(skb)->end_seq = tp->write_seq;
-	TCP_SKB_CB(skb)->flags = TCPCB_FLAG_ACK;
-	TCP_SKB_CB(skb)->sacked = 0;
+	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
+
+	skb->csum    = 0;
+	tcb->seq     = tcb->end_seq = tp->write_seq;
+	tcb->flags   = TCPCB_FLAG_ACK;
+	tcb->sacked  = 0;
 	skb_header_release(skb);
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 	sk_charge_skb(sk, skb);
-- 
1.4.2.1.g3d5c

