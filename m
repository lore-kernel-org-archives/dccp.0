From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Oct 2007 08:43:56 +0000
Subject: [PATCH 7/14]: No more CCID control blocks in LISTEN state
Message-Id: <200710110943.56404@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.43141@strip-the-willow>
In-Reply-To: <200710031502.43141@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Kernel 2.6.23 is out and I have updated this patch with a small change
which concerns the initialisation of hcrx/hctx after testing for OPEN|LISTEN|PARTOPEN.

Also updated the changelog for this patch. Ian - please check whether you are still ok
with this patch.

-------------------------------> Patch v2 <--------------------------------------------
[CCID3]: No more CCID control blocks in LISTEN state

The CCIDs are activated as last of the features, at the end of the handshake, were
the LISTEN state of the master socket is inherited into the server state of the child
socket. Thus, the only states visible to CCIDs now are OPEN/PARTOPEN, and the closing
states.
This allows to remove tests which were previously necessary to protect against referencing
a socket in the listening state (in CCID3), but which now have become redundant.

Thanks to Ian McDonald for discussion on this.

As a further byproduct of enabling the CCIDs only after the connection has been fully 
established, several typecast-initialisations of ccid3_hc_{rx,tx}_sock can now be eliminated:
 * the CCID is loaded, so it is not necessary to test if it is NULL,
 * if it is possible to load a CCID and leave the private area NULL, then this is a bug, which
   should crash loudly and earlier,
 * the test for state=OPEN || state=PARTOPEN now reduces only to the closing phase (e.g. when
   the node has received an unexpected Reset).		  

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   40 +++++++---------------------------------
 1 file changed, 7 insertions(+), 33 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -595,28 +595,16 @@ static void ccid3_hc_tx_exit(struct sock
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	struct ccid3_hc_tx_sock *hctx;
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return;
-
-	hctx = ccid3_hc_tx_sk(sk);
-	info->tcpi_rto = hctx->ccid3hctx_t_rto;
-	info->tcpi_rtt = hctx->ccid3hctx_rtt;
+	info->tcpi_rto = ccid3_hc_tx_sk(sk)->ccid3hctx_t_rto;
+	info->tcpi_rtt = ccid3_hc_tx_sk(sk)->ccid3hctx_rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_tx_sock *hctx;
+	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	const void *val;
 
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
-	hctx = ccid3_hc_tx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
 		if (len < sizeof(hctx->ccid3hctx_tfrc))
@@ -723,14 +711,12 @@ static void ccid3_hc_rx_send_feedback(st
 
 static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct ccid3_hc_rx_sock *hcrx;
+	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
 
-	hcrx = ccid3_hc_rx_sk(sk);
-
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
@@ -889,30 +875,18 @@ static void ccid3_hc_rx_exit(struct sock
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	const struct ccid3_hc_rx_sock *hcrx;
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return;
-
-	hcrx = ccid3_hc_rx_sk(sk);
-	info->tcpi_ca_state = hcrx->ccid3hcrx_state;
+	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->ccid3hcrx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = hcrx->ccid3hcrx_rtt;
+	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->ccid3hcrx_rtt;
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_rx_sock *hcrx;
+	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	const void *val;
 	struct tfrc_rx_info rx_info;
 
-	/* Listen socks don't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
-	hcrx = ccid3_hc_rx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
