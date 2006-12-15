From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 10:51:10 +0000
Subject: [PATCH 7/8]: Re-order CCID 3 source file
Message-Id: <200612151051.10444@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Re-order CCID 3 source file

No code change at all. 
This splits ccid3.c into a RX and a TX section, so that the file has an
organisation similar to the other ones (e.g. packet_history.{h,c}).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   88 +++++++++++++++++++++++++------------------------
 1 file changed, 45 insertions(+), 43 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -33,7 +33,6 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-
 #include "../ccid.h"
 #include "../dccp.h"
 #include "lib/packet_history.h"
@@ -45,6 +44,9 @@ static struct dccp_tx_hist *ccid3_tx_his
 static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
 
+/*
+ *	Transmitter Half-Connection Routines
+ */
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 {
@@ -638,10 +640,50 @@ static void ccid3_hc_tx_exit(struct sock
 	dccp_tx_hist_purge(ccid3_tx_hist, &hctx->ccid3hctx_hist);
 }
 
+static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
+{
+	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+
+	/* Listen socks doesn't have a private CCID block */
+	if (sk->sk_state = DCCP_LISTEN)
+		return;
+
+	BUG_ON(hctx = NULL);
+
+	info->tcpi_rto = hctx->ccid3hctx_t_rto;
+	info->tcpi_rtt = hctx->ccid3hctx_rtt;
+}
+
+static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
+				  u32 __user *optval, int __user *optlen)
+{
+	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	const void *val;
+
+	/* Listen socks doesn't have a private CCID block */
+	if (sk->sk_state = DCCP_LISTEN)
+		return -EINVAL;
+
+	switch (optname) {
+	case DCCP_SOCKOPT_CCID_TX_INFO:
+		if (len < sizeof(hctx->ccid3hctx_tfrc))
+			return -EINVAL;
+		len = sizeof(hctx->ccid3hctx_tfrc);
+		val = &hctx->ccid3hctx_tfrc;
+		break;
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	if (put_user(len, optlen) || copy_to_user(optval, val, len))
+		return -EFAULT;
+
+	return 0;
+}
+
 /*
- * RX Half Connection methods
+ *	Receiver Half-Connection Routines
  */
-
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 {
@@ -1126,20 +1168,6 @@ static void ccid3_hc_rx_get_info(struct 
 	info->tcpi_rcv_rtt  = hcrx->ccid3hcrx_rtt;
 }
 
-static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
-{
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return;
-
-	BUG_ON(hctx = NULL);
-
-	info->tcpi_rto = hctx->ccid3hctx_t_rto;
-	info->tcpi_rtt = hctx->ccid3hctx_rtt;
-}
-
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
@@ -1167,32 +1195,6 @@ static int ccid3_hc_rx_getsockopt(struct
 	return 0;
 }
 
-static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
-				  u32 __user *optval, int __user *optlen)
-{
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const void *val;
-	
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
-	switch (optname) {
-	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->ccid3hctx_tfrc))
-			return -EINVAL;
-		len = sizeof(hctx->ccid3hctx_tfrc);
-		val = &hctx->ccid3hctx_tfrc;
-		break;
-	default:
-		return -ENOPROTOOPT;
-	}
-
-	if (put_user(len, optlen) || copy_to_user(optval, val, len))
-		return -EFAULT;
-
-	return 0;
-}
 
 static struct ccid_operations ccid3 = {
 	.ccid_id		   = DCCPC_CCID3,
