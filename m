From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 29 Jun 2007 14:07:37 +0000
Subject: [Patch v2  2/3]: Use a function to update p_inv, and p is never used
Message-Id: <200706291507.37497@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am resubmitting this since the original patch had a bug:
 * original patch was on http://www.mail-archive.com/dccp@vger.kernel.org/msg01937.html
 * when applying scaled_div(1, hcrx->ccid3hcrx_pinv) to an unitialised `pinv', 
   there would have been a divide-by-zero exception (BUG)
 * replaced by explicit test, return ~0U instead (as in RFC 4342, sec. 8.5)
 * also moved the initialisation to where it is actually being used.

-------------------------------------> Patch v2 <-------------------------------------
[CCID 3]: Use a function to update p_inv, and p is never used

This patch
 1) concentrates previously scattered computation of p_inv into one function;
 2) removes the `p' element of the CCID3 RX sock (it is redundant);
 3) makes the tfrc_rx_info structure standalone, only used on demand.

The reason for (2) is that the code essentially only uses p_inv = 1/p. It does not
need p, since all the relevant information is already in p_inv.
The motivation for (3) is that the embedded info structure will not be used often,
so that the extra cost of keeping p in synch with p_inv (which has to be done at
each packet reception) is overhead most of the time.

Advantages that this buys:
--------------------------
 * the RX sock loses further weight;
 * computation of p_inv is no longer scattered in different places;
 * not having to keep p in sync with p_inv speeds up computation
   (important, as p_inv has to be recomputed for each new data packet);
 * several test cases can now be removed since all is in one function;
 * the send_feedback and packet_recv code becomes simpler.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   13 +++++++++----
 net/dccp/ccids/ccid3.h |   11 ++++-------
 2 files changed, 13 insertions(+), 11 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -141,12 +141,11 @@ enum ccid3_fback_type {
 
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
@@ -154,13 +153,11 @@ enum ccid3_fback_type {
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
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -902,17 +902,22 @@ static int ccid3_hc_rx_getsockopt(struct
 {
 	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	const void *val;
+	struct tfrc_rx_info rx_info;
 
-	/* Listen socks doesn't have a private CCID block */
+	/* Listen socks don't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
 		return -EINVAL;
 
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
+		rx_info.tfrcrx_p	= hcrx->ccid3hcrx_pinv = 0? ~0U
+					: scaled_div(1, hcrx->ccid3hcrx_pinv);
 		break;
 	default:
 		return -ENOPROTOOPT;
