From: Hariprasad Kelam <hariprasad.kelam@gmail.com>
Date: Sun, 12 May 2019 10:51:49 +0000
Subject: [PATCH] net: dccp : proto: remove Unneeded variable "err"
Message-Id: <20190512103949.GA2554@hari-Inspiron-1545>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Fix below issue reported by coccicheck


net/dccp/proto.c:266:5-8: Unneeded variable: "err". Return "0" on line
310

Signed-off-by: Hariprasad Kelam <hariprasad.kelam@gmail.com>
---
 net/dccp/proto.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 0e2f71a..5dd85ec 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -263,7 +263,6 @@ int dccp_disconnect(struct sock *sk, int flags)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	int err = 0;
 	const int old_state = sk->sk_state;
 
 	if (old_state != DCCP_CLOSED)
@@ -307,7 +306,7 @@ int dccp_disconnect(struct sock *sk, int flags)
 	WARN_ON(inet->inet_num && !icsk->icsk_bind_hash);
 
 	sk->sk_error_report(sk);
-	return err;
+	return 0;
 }
 
 EXPORT_SYMBOL_GPL(dccp_disconnect);
-- 
2.7.4
