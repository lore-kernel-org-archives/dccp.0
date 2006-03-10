From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 7/9] [SELINUX]: selinux_socket_getpeer_{stream,dgram} fixup
Message-Id: <11420257372486-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Catherine Zhang <cxzhang@watson.ibm.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 security/selinux/include/xfrm.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

4efa8434cce5535cefea8e9f44fada7136159722
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index a7f388b..c10f1fc 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -51,6 +51,16 @@ static inline int selinux_xfrm_postroute
 {
 	return NF_ACCEPT;
 }
+
+static inline int selinux_socket_getpeer_stream(struct sock *sk)
+{
+	return SECSID_NULL;
+}
+
+static inline int selinux_socket_getpeer_dgram(struct sk_buff *skb)
+{
+	return SECSID_NULL;
+}
 #endif
 
 #endif /* _SELINUX_XFRM_H_ */
-- 
1.2.2.gd27d


