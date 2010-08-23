From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Aug 2010 05:41:37 +0000
Subject: [PATCH 2/5] dccp ccid-3: No more CCID control blocks in LISTEN state
Message-Id: <1282542100-5799-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The CCIDs are activated as last of the features, at the end of the handshake,
were the LISTEN state of the master socket is inherited into the server
state of the child socket. Thus, the only states visible to CCIDs now are
OPEN/PARTOPEN, and the closing states.

This allows to remove tests which were previously necessary to protect
against referencing a socket in the listening state (in CCID-3), but which
now have become redundant.

As a further byproduct of enabling the CCIDs only after the connection has been
fully established, several typecast-initialisations of ccid3_hc_{rx,tx}_sock
can now be eliminated:
 * the CCID is loaded, so it is not necessary to test if it is NULL,
 * if it is possible to load a CCID and leave the private area NULL, then this
    is a bug, which should crash loudly - and earlier,
 * the test for state=OPEN || state=PARTOPEN now reduces only to the closing
   phase (e.g. when the node has received an unexpected Reset).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   40 +++++++---------------------------------
 1 files changed, 7 insertions(+), 33 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -564,29 +564,17 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	struct ccid3_hc_tx_sock *hc;
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return;
-
-	hc = ccid3_hc_tx_sk(sk);
-	info->tcpi_rto = hc->tx_t_rto;
-	info->tcpi_rtt = hc->tx_rtt;
+	info->tcpi_rto = ccid3_hc_tx_sk(sk)->tx_t_rto;
+	info->tcpi_rtt = ccid3_hc_tx_sk(sk)->tx_rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_tx_sock *hc;
+	const struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 	struct tfrc_tx_info tfrc;
 	const void *val;
 
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
-	hc = ccid3_hc_tx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
 		if (len < sizeof(tfrc))
@@ -706,14 +694,12 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 
 static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct ccid3_hc_rx_sock *hc;
+	const struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
 
-	hc = ccid3_hc_rx_sk(sk);
-
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
@@ -876,30 +862,18 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	const struct ccid3_hc_rx_sock *hc;
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return;
-
-	hc = ccid3_hc_rx_sk(sk);
-	info->tcpi_ca_state = hc->rx_state;
+	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->rx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = hc->rx_rtt;
+	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->rx_rtt;
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_rx_sock *hc;
+	const struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 	struct tfrc_rx_info rx_info;
 	const void *val;
 
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
-	hc = ccid3_hc_rx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
