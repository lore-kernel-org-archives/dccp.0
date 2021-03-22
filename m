From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 22 Mar 2021 10:43:32 +0000
Subject: [PATCH net-next 2/5] dccp: avoid Wempty-body warning
Message-Id: <20210322104343.948660-2-arnd@kernel.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

There are a couple of warnings in this driver when building with W=1:

net/dccp/output.c: In function 'dccp_xmit_packet':
net/dccp/output.c:283:71: error: suggest braces around empty body in an 'if' statement [-Werror=empty-body]
  283 |                 dccp_pr_debug("transmit_skb() returned err=%d\n", err);
      |                                                                       ^
net/dccp/ackvec.c: In function 'dccp_ackvec_update_old':
net/dccp/ackvec.c:163:80: error: suggest braces around empty body in an 'else' statement [-Werror=empty-body]
  163 |                                               (unsigned long long)seqno, state);
      |                                                                                ^

Change the empty debug macros to no_printk(), which avoids the
warnings and adds useful format string checks.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/dccp/dccp.h  | 6 +++---
 net/dccp/proto.c | 2 --
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 9cc9d1ee6cdb..8a5163620bc3 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -41,9 +41,9 @@ extern bool dccp_debug;
 #define dccp_pr_debug_cat(format, a...)   DCCP_PRINTK(dccp_debug, format, ##a)
 #define dccp_debug(fmt, a...)		  dccp_pr_debug_cat(KERN_DEBUG fmt, ##a)
 #else
-#define dccp_pr_debug(format, a...)
-#define dccp_pr_debug_cat(format, a...)
-#define dccp_debug(format, a...)
+#define dccp_pr_debug(format, a...)	  no_printk(format, ##a)
+#define dccp_pr_debug_cat(format, a...)	  no_printk(format, ##a)
+#define dccp_debug(format, a...)	  no_printk(format, ##a)
 #endif
 
 extern struct inet_hashinfo dccp_hashinfo;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 6d705d90c614..97a175eaf247 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -51,7 +51,6 @@ EXPORT_SYMBOL_GPL(dccp_hashinfo);
 /* the maximum queue length for tx in packets. 0 is no limit */
 int sysctl_dccp_tx_qlen __read_mostly = 5;
 
-#ifdef CONFIG_IP_DCCP_DEBUG
 static const char *dccp_state_name(const int state)
 {
 	static const char *const dccp_state_names[] = {
@@ -73,7 +72,6 @@ static const char *dccp_state_name(const int state)
 	else
 		return dccp_state_names[state];
 }
-#endif
 
 void dccp_set_state(struct sock *sk, const int state)
 {
-- 
2.29.2
