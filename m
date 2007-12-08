From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Dec 2007 10:06:28 +0000
Subject: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with newer Loss Intervals Database
Message-Id: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This hooks up the TFRC Loss Interval database with CCID 3 packet reception.
In addition, it makes the CCID-specific computation of the first loss
interval (which requires access to all the guts of CCID3) local to ccid3.c.

The patch also fixes an omission in the DCCP code, that of a default /
fallback RTT value (defined in section 3.4 of RFC 4340 as 0.2 sec); while
at it, the  upper bound of 4 seconds for an RTT sample has  been reduced to
match the initial TCP RTO value of 3 seconds from[RFC 1122, 4.2.3.1].

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   72 ++++++++++++++++++++++++++++++++++++++++--------
 net/dccp/ccids/ccid3.h |   10 +++---
 net/dccp/dccp.h        |    7 +++-
 3 files changed, 70 insertions(+), 19 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 60fcb31..4d0de21 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1,6 +1,7 @@
 /*
  *  net/dccp/ccids/ccid3.c
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
@@ -33,11 +34,7 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-#include "../ccid.h"
 #include "../dccp.h"
-#include "lib/packet_history.h"
-#include "lib/loss_interval.h"
-#include "lib/tfrc.h"
 #include "ccid3.h"
 
 #include <asm/unaligned.h>
@@ -759,6 +756,46 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
+/** ccid3_first_li  -  Implements [RFC 3448, 6.3.1]
+ *
+ * Determine the length of the first loss interval via inverse lookup.
+ * Assume that X_recv can be computed by the throughput equation
+ *		    s
+ *	X_recv = --------
+ *		 R * fval
+ * Find some p such that f(p) = fval; return 1/p (scaled).
+ */
+static u32 ccid3_first_li(struct sock *sk)
+{
+	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	u32 x_recv, p, delta;
+	u64 fval;
+
+	if (hcrx->ccid3hcrx_rtt = 0) {
+		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
+		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
+	}
+
+	delta = ktime_to_us(net_timedelta(hcrx->ccid3hcrx_tstamp_last_feedback));
+	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	if (x_recv = 0) {		/* would also trigger divide-by-zero */
+		DCCP_WARN("X_recv=0\n");
+		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
+			DCCP_BUG("stored value of X_recv is zero");
+			return ~0U;
+		}
+	}
+
+	fval = scaled_div(hcrx->ccid3hcrx_s, hcrx->ccid3hcrx_rtt);
+	fval = scaled_div32(fval, x_recv);
+	p = tfrc_calc_x_reverse_lookup(fval);
+
+	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
+		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
+
+	return p = 0 ? ~0U : scaled_div(1, p);
+}
+
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
@@ -796,6 +833,14 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	/*
 	 * Handle pending losses and otherwise check for new loss
 	 */
+	if (tfrc_rx_hist_loss_pending(&hcrx->ccid3hcrx_hist) &&
+	    tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
+				&hcrx->ccid3hcrx_li_hist,
+				skb, ndp, ccid3_first_li, sk) ) {
+		do_feedback = CCID3_FBACK_PARAM_CHANGE;
+		goto done_receiving;
+	}
+
 	if (tfrc_rx_hist_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
 		goto update_records;
 
@@ -805,7 +850,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
+	if (!tfrc_lh_is_initialised(&hcrx->ccid3hcrx_li_hist)) {
 		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
 		/*
 		 * Empty loss history: no loss so far, hence p stays 0.
@@ -814,6 +859,13 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (sample != 0)
 			hcrx->ccid3hcrx_rtt = tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
+
+	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb)) {
+		/*
+		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
+		 * has decreased (resp. p has increased), send feedback now.
+		 */
+		do_feedback = CCID3_FBACK_PARAM_CHANGE;
 	}
 
 	/*
@@ -825,6 +877,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 update_records:
 	tfrc_rx_hist_add_packet(&hcrx->ccid3hcrx_hist, skb, ndp);
 
+done_receiving:
 	if (do_feedback)
 		ccid3_hc_rx_send_feedback(sk, skb, do_feedback);
 }
@@ -833,10 +886,8 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	ccid3_pr_debug("entry\n");
-
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
+	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
 	return tfrc_rx_hist_alloc(&hcrx->ccid3hcrx_hist);
 }
 
@@ -846,11 +897,8 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	/* Empty packet history */
 	tfrc_rx_hist_purge(&hcrx->ccid3hcrx_hist);
-
-	/* Empty loss interval history */
-	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
+	tfrc_lh_cleanup(&hcrx->ccid3hcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 3c33dc6..2dede8e 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -41,7 +41,7 @@
 #include <linux/list.h>
 #include <linux/types.h>
 #include <linux/tfrc.h>
-#include "lib/packet_history.h"
+#include "lib/tfrc.h"
 #include "../ccid.h"
 
 /* Two seconds as per RFC 3448 4.2 */
@@ -141,8 +141,8 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
- *  @ccid3hcrx_hist  -  Packet history
- *  @ccid3hcrx_li_hist  -  Loss Interval History
+ *  @ccid3hcrx_hist  -  Packet history (loss detection + RTT sampling)
+ *  @ccid3hcrx_li_hist  -  Loss Interval database
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
@@ -156,9 +156,9 @@ struct ccid3_hc_rx_sock {
 	u32				ccid3hcrx_bytes_recv;
 	ktime_t				ccid3hcrx_tstamp_last_feedback;
 	struct tfrc_rx_hist		ccid3hcrx_hist;
-	struct list_head		ccid3hcrx_li_hist;
+	struct tfrc_loss_hist		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
-	u32				ccid3hcrx_pinv;
+#define ccid3hcrx_pinv			ccid3hcrx_li_hist.i_mean
 };
 
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f4a5ea1..07dcbe7 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -74,9 +74,12 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 
 #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
 
-/* bounds for sampled RTT values from packet exchanges (in usec) */
+/*
+ * RTT sampling: sanity bounds and fallback RTT value from RFC 4340, section 3.4
+ */
 #define DCCP_SANE_RTT_MIN	100
-#define DCCP_SANE_RTT_MAX	(4 * USEC_PER_SEC)
+#define DCCP_FALLBACK_RTT	(USEC_PER_SEC / 5)
+#define DCCP_SANE_RTT_MAX	(3 * USEC_PER_SEC)
 
 /* Maximal interval between probes for local resources.  */
 #define DCCP_RESOURCE_PROBE_INTERVAL ((unsigned)(HZ / 2U))
