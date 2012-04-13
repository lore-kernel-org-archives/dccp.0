From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Apr 2012 08:16:05 +0000
Subject: [PATCH net-next] inet: makes syn_ack_timeout mandatory
Message-Id: <1334304965.5300.8713.camel@edumazet-glaptop>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: : Eric Dumazet <edumazet@google.com>

There are two struct request_sock_ops providers, tcp and dccp.

inet_csk_reqsk_queue_prune() can avoid testing syn_ack_timeout being
NULL if we make it non NULL like syn_ack_timeout

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org
---
 include/linux/dccp.h            |    2 ++
 net/dccp/ipv4.c                 |    6 ++++++
 net/dccp/ipv6.c                 |    1 +
 net/ipv4/inet_connection_sock.c |    3 +--
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index eaf95a0..d16294e 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -549,6 +549,8 @@ static inline const char *dccp_role(const struct sock *sk)
 	return NULL;
 }
 
+extern void dccp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_DCCP_H */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index caf6e17..059cda9 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -574,6 +574,11 @@ static void dccp_v4_reqsk_destructor(struct request_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
 
+void dccp_syn_ack_timeout(struct sock *sk, struct request_sock *req)
+{
+}
+EXPORT_SYMBOL(dccp_syn_ack_timeout);
+
 static struct request_sock_ops dccp_request_sock_ops __read_mostly = {
 	.family		= PF_INET,
 	.obj_size	= sizeof(struct dccp_request_sock),
@@ -581,6 +586,7 @@ static struct request_sock_ops dccp_request_sock_ops __read_mostly = {
 	.send_ack	= dccp_reqsk_send_ack,
 	.destructor	= dccp_v4_reqsk_destructor,
 	.send_reset	= dccp_v4_ctl_send_reset,
+	.syn_ack_timeout = dccp_syn_ack_timeout,
 };
 
 int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4dc588f..bd539b2 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -343,6 +343,7 @@ static struct request_sock_ops dccp6_request_sock_ops = {
 	.send_ack	= dccp_reqsk_send_ack,
 	.destructor	= dccp_v6_reqsk_destructor,
 	.send_reset	= dccp_v6_ctl_send_reset,
+	.syn_ack_timeout = dccp_syn_ack_timeout,
 };
 
 static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 19d66ce..664e9fc 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -555,8 +555,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 				syn_ack_recalc(req, thresh, max_retries,
 					       queue->rskq_defer_accept,
 					       &expire, &resend);
-				if (req->rsk_ops->syn_ack_timeout)
-					req->rsk_ops->syn_ack_timeout(parent, req);
+				req->rsk_ops->syn_ack_timeout(parent, req);
 				if (!expire &&
 				    (!resend ||
 				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||


