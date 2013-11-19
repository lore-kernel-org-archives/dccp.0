From: Wang Weidong <wangweidong1@huawei.com>
Date: Tue, 19 Nov 2013 02:47:27 +0000
Subject: [PATCH 2/2] ipv6: use sk_v6_copy_addrs when memcpy struct ipv6_pinfo
Message-Id: <1384829247-8624-3-git-send-email-wangweidong1@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

commit efe4208f ("ipv6: make lookups simpler and faster") remove
the daddr and rcv_saddr from struct ipv6_pinfo. When use memcpy
the ipv6_pinfo, we lose the sk_v6_daddr and sk_v6_rcv_saddr, so
use the sk_v6_copy_addrs when needed.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/dccp/ipv6.c     | 4 ++++
 net/ipv6/tcp_ipv6.c | 4 ++++
 net/sctp/ipv6.c     | 4 ++++
 3 files changed, 12 insertions(+)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4ac71ff..90182a8 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -465,6 +465,10 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		newnp = inet6_sk(newsk);
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+		/* Don't forget copy the rcv_saddr and daddr when
+		 * copy ipv6_pinfo.
+		 */
+		sk_v6_copy_addrs(newsk, sk);
 
 		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0740f93..83d011e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1116,6 +1116,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newtp = tcp_sk(newsk);
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+		/* Don't forget copy the rcv_saddr and daddr when
+		 * copy ipv6_pinfo.
+		 */
+		sk_v6_copy_addrs(newsk, sk);
 
 		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 7567e6f..b76f143 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -656,6 +656,10 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 	newnp = inet6_sk(newsk);
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+	/* Don't forget copy the rcv_saddr and daddr when
+	 * copy ipv6_pinfo.
+	 */
+	sk_v6_copy_addrs(newsk, sk);
 
 	/* Initialize sk's sport, dport, rcv_saddr and daddr for getsockname()
 	 * and getpeername().
-- 
1.7.12


