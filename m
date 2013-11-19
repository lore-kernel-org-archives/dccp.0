From: Wang Weidong <wangweidong1@huawei.com>
Date: Tue, 19 Nov 2013 02:47:26 +0000
Subject: [PATCH 1/2] ipv6: add helper function for copy addrs from old sock
Message-Id: <1384829247-8624-2-git-send-email-wangweidong1@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Add sk_v6_copy_addrs for copying sk_v6_daddr and sk_v6_rcv_saddr, it
will be used in the coming patch.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sock.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index e3a18ff..9be2b9f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -442,6 +442,12 @@ struct sock {
 #define SK_CAN_REUSE	1
 #define SK_FORCE_REUSE	2
 
+static inline void sk_v6_copy_addrs(struct sock *newsk, struct sock *oldsk)
+{
+	newsk->sk_v6_daddr = oldsk->sk_v6_daddr;
+	newsk->sk_v6_rcv_saddr = oldsk->sk_v6_rcv_saddr;
+}
+
 static inline int sk_peek_offset(struct sock *sk, int flags)
 {
 	if ((flags & MSG_PEEK) && (sk->sk_peek_off >= 0))
-- 
1.7.12


