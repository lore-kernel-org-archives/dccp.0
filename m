From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 22 Mar 2019 15:44:09 +0000
Subject: [BACKPORT 4.4.y 18/25] tcp/dccp: drop SYN packets if accept queue is full
Message-Id: <20190322154425.3852517-19-arnd@arndb.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Per listen(fd, backlog) rules, there is really no point accepting a SYN,
sending a SYNACK, and dropping the following ACK packet if accept queue
is full, because application is not draining accept queue fast enough.

This behavior is fooling TCP clients that believe they established a
flow, while there is nothing at server side. They might then send about
10 MSS (if using IW10) that will be dropped anyway while server is under
stress.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
(cherry picked from commit 5ea8ea2cb7f1d0db15762c9b0bb9e7330425a071)
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/net/inet_connection_sock.h | 5 -----
 net/dccp/ipv4.c                    | 8 +-------
 net/dccp/ipv6.c                    | 2 +-
 net/ipv4/tcp_input.c               | 8 +-------
 4 files changed, 3 insertions(+), 20 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 49dcad4fe99e..72599bbc8255 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -289,11 +289,6 @@ static inline int inet_csk_reqsk_queue_len(const struct sock *sk)
 	return reqsk_queue_len(&inet_csk(sk)->icsk_accept_queue);
 }
 
-static inline int inet_csk_reqsk_queue_young(const struct sock *sk)
-{
-	return reqsk_queue_len_young(&inet_csk(sk)->icsk_accept_queue);
-}
-
 static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
 {
 	return inet_csk_reqsk_queue_len(sk) >= sk->sk_max_ack_backlog;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 45fd82e61e79..b0a577a79a6a 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -592,13 +592,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (inet_csk_reqsk_queue_is_full(sk))
 		goto drop;
 
-	/*
-	 * Accept backlog is full. If we have already queued enough
-	 * of warm entries in syn queue, drop request. It is better than
-	 * clogging syn queue with openreqs with exponentially increasing
-	 * timeout.
-	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk))
 		goto drop;
 
 	req = inet_reqsk_alloc(&dccp_request_sock_ops, sk, true);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 0bf41faeffc4..18bb2a42f0d1 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -324,7 +324,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (inet_csk_reqsk_queue_is_full(sk))
 		goto drop;
 
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk))
 		goto drop;
 
 	req = inet_reqsk_alloc(&dccp6_request_sock_ops, sk, true);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1aff93d76f24..b320fa9f834a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6305,13 +6305,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			goto drop;
 	}
 
-
-	/* Accept backlog is full. If we have already queued enough
-	 * of warm entries in syn queue, drop request. It is better than
-	 * clogging syn queue with openreqs with exponentially increasing
-	 * timeout.
-	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
+	if (sk_acceptq_is_full(sk)) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 		goto drop;
 	}
-- 
2.20.0
