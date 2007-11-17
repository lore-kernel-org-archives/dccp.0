From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Nov 2007 09:29:41 +0000
Subject: [PATCH 14/16] [CCID 3]: Use a function to update p_inv, and p is never used
Message-Id: <11952917843264-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch
 1) removes the redundant `p' field member of the CCID3 RX sock;
 2) concentrates previously scattered computation of p_inv into one function;
 3) makes the tfrc_rx_info structure standalone, only used on demand.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   11 ++++++++---
 net/dccp/ccids/ccid3.h |   11 ++++-------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index ea218b2..18ace1c 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -908,6 +908,7 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 {
 	const struct ccid3_hc_rx_sock *hcrx;
 	const void *val;
+	struct tfrc_rx_info rx_info;
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
@@ -916,10 +917,14 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 	hcrx = ccid3_hc_rx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
-		if (len < sizeof(hcrx->ccid3hcrx_tfrc))
+		if (len < sizeof(rx_info))
 			return -EINVAL;
-		len = sizeof(hcrx->ccid3hcrx_tfrc);
-		val = &hcrx->ccid3hcrx_tfrc;
+		len = sizeof(rx_info);
+		val = &rx_info;
+		rx_info.tfrcrx_x_recv	= hcrx->ccid3hcrx_x_recv;
+		rx_info.tfrcrx_rtt	= hcrx->ccid3hcrx_rtt;
+		rx_info.tfrcrx_p	= hcrx->ccid3hcrx_pinv = 0 ? ~0U
+					: scaled_div(1, hcrx->ccid3hcrx_pinv);
 		break;
 	default:
 		return -ENOPROTOOPT;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index b156359..36fa44c 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -140,12 +140,11 @@ enum ccid3_fback_type {
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
- *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
- *  @ccid3hcrx_p  -  current loss event rate (RFC 3448 5.4)
  *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
+ *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ *  @ccid3hcrx_rtt  -  Receiver estimate of RTT
  *  @ccid3hcrx_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history, exported by TFRC module
  *  @ccid3hcrx_li_hist  -  Loss Interval database, exported by TFRC module
@@ -153,13 +152,11 @@ enum ccid3_fback_type {
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
 struct ccid3_hc_rx_sock {
-	struct tfrc_rx_info		ccid3hcrx_tfrc;
-#define ccid3hcrx_x_recv		ccid3hcrx_tfrc.tfrcrx_x_recv
-#define ccid3hcrx_rtt			ccid3hcrx_tfrc.tfrcrx_rtt
-#define ccid3hcrx_p			ccid3hcrx_tfrc.tfrcrx_p
 	u8				ccid3hcrx_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
+	u32				ccid3hcrx_x_recv;
+	u32				ccid3hcrx_rtt;
 	ktime_t				ccid3hcrx_last_feedback;
 	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct tfrc_loss_hist		ccid3hcrx_li_hist;
-- 
1.5.2.2.238.g7cbf2f2-dirty

