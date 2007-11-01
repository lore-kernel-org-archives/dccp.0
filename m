From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:32:08 +0000
Subject: [PATCH 24/25] Final adjustments to probe.c to use tfrc_ccids
Message-Id: <200710312132.08440.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP] Final adjustments to probe.c to use ccid34_lib

According to the chosen strategy explained in [PATCH 15/25], some defines become unnecessary. This patch removes them and adjusts probe.c to use ccid34_lib definitions directly

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/probe.c
=================================--- leandro.new.orig/net/dccp/probe.c
+++ leandro.new/net/dccp/probe.c
@@ -76,25 +76,19 @@ static void printl(const char *fmt, ...)
 	wake_up(&dccpw.wait);
 }
 
-#define ccid3_hc_tx_sock tfrc_hc_tx_sock
-#define ccid3hctx_s tfrchctx_s
-#define ccid3hctx_p tfrchctx_p
-#define ccid3hctx_rtt tfrchctx_rtt
-#define ccid3hctx_x_calc tfrchctx_x_calc
-#define ccid3hctx_x_recv tfrchctx_x_recv
-#define ccid3hctx_x tfrchctx_x
-#define ccid3hctx_t_ipi tfrchctx_t_ipi
-
-#define ccid3_hc_tx_sk tfrc_hc_tx_sk
-
 static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			 struct msghdr *msg, size_t size)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = NULL;
+	struct tfrc_hc_tx_sock *hctx = NULL;
 
-	if (ccid_get_current_id(dccp_sk(sk), false) = DCCPC_CCID3)
-		hctx = ccid3_hc_tx_sk(sk);
+        int current_ccid = ccid_get_current_id(dccp_sk(sk), false);
+        switch (current_ccid) {
+                case DCCPC_CCID3:
+                case DCCPC_CCID4:
+		        hctx = tfrc_hc_tx_sk(sk);
+                        break;
+        }
 
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
