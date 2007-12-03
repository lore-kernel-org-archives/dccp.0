From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Dec 2007 11:28:40 +0000
Subject: [PATCH 6/6] [CCID]: Interface CCID3 code with newer Loss Intervals Database
Message-Id: <11966813202833-git-send-email-gerrit@erg.abdn.ac.uk>
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
 net/dccp/ccids/ccid3.c |   76 +++++++++++++++++++++++++++++++++++++++--------
 net/dccp/ccids/ccid3.h |    8 ++--
 net/dccp/dccp.h        |    7 +++-
 3 files changed, 72 insertions(+), 19 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index ef243dc..bf6d043 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -34,11 +34,7 @@
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
@@ -751,6 +747,46 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
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
+	delta = ktime_to_us(net_timedelta(hcrx->ccid3hcrx_last_feedback));
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
@@ -779,6 +815,14 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	/*
 	 *	Handle pending losses and otherwise check for new loss
 	 */
+	if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist) &&
+	    tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
+				&hcrx->ccid3hcrx_li_hist,
+				skb, ndp, ccid3_first_li, sk) ) {
+		do_feedback = FBACK_PARAM_CHANGE;
+		goto done_receiving;
+	}
+
 	if (tfrc_rx_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
 		goto update_records;
 
@@ -788,13 +832,23 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
-
+	if (! tfrc_lh_is_initialised(&hcrx->ccid3hcrx_li_hist)) {
+		/*
+		 * Empty loss history: no loss so far, hence p stays 0.
+		 * Sample RTT values, since an RTT estimate is required for the
+		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
+		 */
 		sample = tfrc_rx_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
 		if (sample != 0)
 			hcrx->ccid3hcrx_rtt  				tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
 
+	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb)) {
+		/*
+		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
+		 * has decreased (resp. p has increased), send feedback now.
+		 */
+		do_feedback = FBACK_PARAM_CHANGE;
 	}
 
 	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
@@ -816,10 +870,8 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 	ccid3_pr_debug("entry\n");
 
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	if (tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist))
-		return 1;
-	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	return 0;
+	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
+	return tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
@@ -829,9 +881,7 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
 	tfrc_rx_hist_cleanup(&hcrx->ccid3hcrx_hist);
-
-	/* Empty loss interval history */
-	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
+	tfrc_lh_cleanup(&hcrx->ccid3hcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 8f7308b..a1a143a 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -40,7 +40,7 @@
 #include <linux/list.h>
 #include <linux/types.h>
 #include <linux/tfrc.h>
-#include "lib/packet_history.h"
+#include "lib/tfrc.h"
 #include "../ccid.h"
 
 /* Two seconds as per RFC 3448 4.2 */
@@ -148,7 +148,7 @@ enum ccid3_fback_type {
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history, exported by TFRC module
- *  @ccid3hcrx_li_hist  -  Loss Interval History
+ *  @ccid3hcrx_li_hist  -  Loss Interval database, exported by TFRC module
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
@@ -162,9 +162,9 @@ struct ccid3_hc_rx_sock {
 	u32				ccid3hcrx_bytes_recv;
 	ktime_t				ccid3hcrx_last_feedback;
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
-- 
