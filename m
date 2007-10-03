From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:43 +0000
Subject: [PATCH 7/14]: No more CCID control blocks in LISTEN state
Message-Id: <200710031502.43141@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: No more CCID control blocks in LISTEN state

The CCIDs are activated as last of the features, at the end of the handshake, were
the LISTEN state of the master socket is inherited into the server state of the child
socket. Thus, the only states visible to CCIDs now are OPEN/PARTOPEN, and the closing
states.
This allows to remove tests which were previously necessary to protect against referencing
a socket in the listening state (in CCID3), but which now have become redundant.

Thanks to Ian McDonald for discussion on this.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   28 ++++------------------------
 1 file changed, 4 insertions(+), 24 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -598,14 +598,8 @@ static void ccid3_hc_tx_exit(struct sock
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return;
-
-	info->tcpi_rto = hctx->ccid3hctx_t_rto;
-	info->tcpi_rtt = hctx->ccid3hctx_rtt;
+	info->tcpi_rto = ccid3_hc_tx_sk(sk)->ccid3hctx_t_rto;
+	info->tcpi_rtt = ccid3_hc_tx_sk(sk)->ccid3hctx_rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
@@ -614,10 +608,6 @@ static int ccid3_hc_tx_getsockopt(struct
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	const void *val;
 
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
 		if (len < sizeof(hctx->ccid3hctx_tfrc))
@@ -897,15 +887,9 @@ static void ccid3_hc_rx_exit(struct sock
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return;
-
-	info->tcpi_ca_state = hcrx->ccid3hcrx_state;
+	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->ccid3hcrx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = hcrx->ccid3hcrx_rtt;
+	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->ccid3hcrx_rtt;
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
@@ -915,10 +899,6 @@ static int ccid3_hc_rx_getsockopt(struct
 	const void *val;
 	struct tfrc_rx_info rx_info;
 
-	/* Listen socks don't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
