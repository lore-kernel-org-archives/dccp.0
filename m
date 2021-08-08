From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 08 Aug 2021 23:04:40 +0000
Subject: [PATCH -net] dccp: add do-while-0 stubs for dccp_pr_debug macros
Message-Id: <20210808230440.15784-1-rdunlap@infradead.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

GCC complains about empty macros in an 'if' statement, so convert
them to 'do {} while (0)' macros.

Fixes these build warnings:

net/dccp/output.c: In function 'dccp_xmit_packet':
../net/dccp/output.c:283:71: warning: suggest braces around empty body in an 'if' statement [-Wempty-body]
  283 |                 dccp_pr_debug("transmit_skb() returned err=%d\n", err);
net/dccp/ackvec.c: In function 'dccp_ackvec_update_old':
../net/dccp/ackvec.c:163:80: warning: suggest braces around empty body in an 'else' statement [-Wempty-body]
  163 |                                               (unsigned long long)seqno, state);

Fixes: dc841e30eaea ("dccp: Extend CCID packet dequeueing interface")
Fixes: 380240864451 ("dccp ccid-2: Update code for the Ack Vector input/registration routine")
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: dccp@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jakub Kicinski <kuba@kernel.org>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-next-20210806.orig/net/dccp/dccp.h
+++ linux-next-20210806/net/dccp/dccp.h
@@ -41,9 +41,9 @@ extern bool dccp_debug;
 #define dccp_pr_debug_cat(format, a...)   DCCP_PRINTK(dccp_debug, format, ##a)
 #define dccp_debug(fmt, a...)		  dccp_pr_debug_cat(KERN_DEBUG fmt, ##a)
 #else
-#define dccp_pr_debug(format, a...)
-#define dccp_pr_debug_cat(format, a...)
-#define dccp_debug(format, a...)
+#define dccp_pr_debug(format, a...)	  do {} while (0)
+#define dccp_pr_debug_cat(format, a...)	  do {} while (0)
+#define dccp_debug(format, a...)	  do {} while (0)
 #endif
 
 extern struct inet_hashinfo dccp_hashinfo;
