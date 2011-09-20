From: Ivo Calado <ivo.calado@ee.ufcg.edu.br>
Date: Tue, 20 Sep 2011 18:13:13 +0000
Subject: [PATCH] Implements Cubic algorithm as a new CCID on DCCP
Message-Id: <CAMKbDfz77zUUX-nmx07mg-Sy-YJSKiwOq7O-q5EnanDziHMpSw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch implements the congestion control algorithm Cubic as a new
CCID for DCCP protocol. This CCID makes use of the cubic function to set
the congestion window to be used in a given time.
Moreover, we use Ack Vectors as the mechanism adopted for confirmation
of received packets. Due to that, the implementation is largely based on
the implementations of Tcp Cubic and CCID-2.

Since the RFC4340 specifies the experimental CCIDs must use ids greater
than 248, we choose 249 as the id to be used, at least for now. However,
we placed the implementation code in a pair of files named ccid5.{h,c}
(since this would be the next available CCID).

This patch can be applied cleanly on top of DCCP test tree branch 'ccid4'.

Signed-off-by: Ivo Calado <ivo.calado@ee.ufcg.edu.br>
Signed-off-by: Leandro Sales <leandroal@gmail.com>
---
 include/linux/dccp.h   |    1 +
 net/dccp/Makefile      |    2 +
 net/dccp/ccid.c        |    3 +
 net/dccp/ccid.h        |    3 +
 net/dccp/ccids/Kconfig |   23 +
 net/dccp/ccids/ccid5.c | 1118 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/ccids/ccid5.h |  164 +++++++
 net/dccp/feat.c        |   26 ++
 8 files changed, 1340 insertions(+), 0 deletions(-)
 create mode 100644 net/dccp/ccids/ccid5.c
 create mode 100644 net/dccp/ccids/ccid5.h

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index f3712c9..1defd8d 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -185,6 +185,7 @@ enum {
 #define DCCPC_TESTING_MIN	248
 #define DCCPC_TESTING_MAX	255
 	DCCPC_CCID_ZERO = DCCPC_TESTING_MIN,
+	DCCPC_CCID_CUBIC,
 };

 /* DCCP features (RFC 4340 section 6.4) */
diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index 6b39be5..ca45ee7 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -21,6 +21,8 @@ dccp-$(CONFIG_IP_DCCP_TFRC_SP_LIB) +=	ccids/lib/tfrc_sp.o		\
 					ccids/lib/loss_interval_sp.o	\
 					ccids/lib/tfrc_ccids_sp.o

+dccp-$(CONFIG_IP_DCCP_CCID5)	+= ccids/ccid5.o
+
 dccp_ipv4-y := ipv4.o

 # build dccp_ipv6 as module whenever either IPv6 or DCCP is a module
diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 9214508..614ad11 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -28,6 +28,9 @@ static struct ccid_operations *ccids[] = {
 #ifdef CONFIG_IP_DCCP_CCID0
 	&ccid0_ops,
 #endif
+#ifdef CONFIG_IP_DCCP_CCID5
+	&ccid5_ops,
+#endif
 };

 static struct ccid_operations *ccid_by_number(const u8 id)
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index 947f40e..4d96840 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -101,6 +101,9 @@ extern struct ccid_operations ccid3_ops;
 #ifdef CONFIG_IP_DCCP_CCID4
 extern struct ccid_operations ccid4_ops;
 #endif
+#ifdef CONFIG_IP_DCCP_CCID5
+extern struct ccid_operations ccid5_ops;
+#endif

 extern int  ccid_initialize_builtins(void);
 extern void ccid_cleanup_builtins(void);
diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index a45d849..1f02e51 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -140,4 +140,27 @@ config IP_DCCP_CCID0

 	  Say N.

+config IP_DCCP_CCID5
+	bool "CCID 5 (DCCP Cubic) (EXPERIMENTAL)"
+	def_bool y if (IP_DCCP = y || IP_DCCP = m)
+	---help---
+	Enable an new experimental CCID called DCCP Cubic.
+
+	DCCP Cubic (with experimental ID 249) is a CCID which performs the
+	congestion control based on Cubic algorithm. For more details about
+	the algorithm consult
+		http://netsrv.csc.ncsu.edu/export/cubic_a_new_tcp_2008.pdf
+	
+config IP_DCCP_CCID5_DEBUG
+	bool "CCID-5 debugging messages"
+	depends on IP_DCCP_CCID5
+	---help---
+	  Enable CCID-5 specific debugging messages.
+
+	  The debugging output can additionally be toggled by setting the
+	  ccid5_debug parameter to 0 or 1.
+
+	  If in doubt, say N.
+
+
 endmenu
diff --git a/net/dccp/ccids/ccid5.c b/net/dccp/ccids/ccid5.c
new file mode 100644
index 0000000..2c1e9c0
--- /dev/null
+++ b/net/dccp/ccids/ccid5.c
@@ -0,0 +1,1118 @@
+/*
+ *  Copyright (c) 2011   Federal University of Campina Grande, Paraiba, BR.
+ *
+ *  An implementation of the DCCP protocol
+ *
+ *  Copyright (c) 2011 Ivo Calado, Leandro Sales
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab. For further information
+ *  please see http://www.embeddedlab.org/
+ *  <ivo.calado@ee.ufcg.edu.br> <leandroal@gmail.com>
+ *
+ *  This code is a version of the Cubic algorithm to the DCCP protocol.
+ *  Due to that, it copies as much code as possible from net/ipv4/tcp_cubic.c
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include "../ccid.h"
+#include "../dccp.h"
+#include "../feat.h"
+#include "ccid5.h"
+
+#ifdef CONFIG_IP_DCCP_CCID5_DEBUG
+static int ccid5_debug;
+#define ccid5_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid5_debug, format, ##a)
+#else
+#define ccid5_pr_debug(format, a...)
+#endif
+
+
+#define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
+					 * max_cwnd = tx_cwnd * beta
+					 */
+#define	CUBIC_DCCP_HZ		10	/* BIC HZ 2^10 = 1024 */
+
+/* Two methods of hybrid slow start */
+#define HYSTART_ACK_TRAIN	0x1
+#define HYSTART_DELAY		0x2
+
+/* Number of delay samples for detecting the increase of delay */
+#define HYSTART_MIN_SAMPLES	8
+#define HYSTART_DELAY_MIN	(2U<<3)
+#define HYSTART_DELAY_MAX	(16U<<3)
+#define HYSTART_DELAY_THRESH(x)	clamp(x, HYSTART_DELAY_MIN, HYSTART_DELAY_MAX)
+
+static int fast_convergence __read_mostly = 1;
+static int beta __read_mostly = 717;	/* = 717/1024 (BICTCP_BETA_SCALE) */
+static int initial_ssthresh __read_mostly;
+static int bic_scale __read_mostly = 41;
+static int tcp_friendliness __read_mostly = 1;
+
+static int hystart __read_mostly = 1;
+static int hystart_detect __read_mostly = HYSTART_ACK_TRAIN | HYSTART_DELAY;
+static int hystart_low_window __read_mostly = 16;
+static int hystart_ack_delta __read_mostly = 2;
+
+static u32 cube_rtt_scale __read_mostly = 1;
+static u32 beta_scale __read_mostly = 1;
+static u64 cube_factor __read_mostly = 1;
+
+/* Note parameters that are used for precomputing scale factors are
read-only */
+module_param(fast_convergence, int, 0644);
+MODULE_PARM_DESC(fast_convergence, "turn on/off fast convergence");
+module_param(beta, int, 0644);
+MODULE_PARM_DESC(beta, "beta for multiplicative increase");
+module_param(initial_ssthresh, int, 0644);
+MODULE_PARM_DESC(initial_ssthresh, "initial value of slow start threshold");
+module_param(bic_scale, int, 0444);
+MODULE_PARM_DESC(bic_scale, "scale (scaled by 1024) value for bic
function (bic_scale/1024)");
+module_param(tcp_friendliness, int, 0644);
+MODULE_PARM_DESC(tcp_friendliness, "turn on/off tcp friendliness");
+module_param(hystart, int, 0644);
+MODULE_PARM_DESC(hystart, "turn on/off hybrid slow start algorithm");
+module_param(hystart_detect, int, 0644);
+MODULE_PARM_DESC(hystart_detect, "hyrbrid slow start detection mechanisms"
+		 " 1: packet-train 2: delay 3: both packet-train and delay");
+module_param(hystart_low_window, int, 0644);
+MODULE_PARM_DESC(hystart_low_window, "lower bound cwnd for hybrid slow start");
+module_param(hystart_ack_delta, int, 0644);
+MODULE_PARM_DESC(hystart_ack_delta, "spacing between ack's indicating
train (msecs)");
+
+
+static inline void bictcp_reset(struct ccid5_hc_tx_sock *hc)
+{
+	hc->tx_cnt = 1;
+	hc->tx_loss_cwnd = 0;
+	hc->tx_last_cwnd = 0;
+	hc->tx_last_time = 0;
+	hc->tx_last_max_cwnd = 0;
+	hc->tx_bic_origin_point = 0;
+	hc->tx_bic_K = 0;
+	hc->tx_delay_min = 0;
+	hc->tx_epoch_start = 0;
+	hc->tx_ack_cnt = 0;
+	hc->tcp_cwnd = 0;
+	hc->tx_cwnd = 1;
+	hc->tx_cwnd_cnt = 0;
+	hc->tx_pipe = 0;
+}
+
+static inline u32 bicdccp_clock(void)
+{
+#if HZ < 1000
+	return ktime_to_ms(ktime_get_real());
+#else
+	return jiffies_to_msecs(jiffies);
+#endif
+}
+
+static inline void ccid5_hc_tx_hystart_reset(struct ccid5_hc_tx_sock *hc)
+{
+	hc->tx_round_start = hc->tx_last_jiffies = bicdccp_clock();
+	hc->tx_curr_rtt = 0;
+	hc->tx_sample_cnt = 0;
+}
+
+static void ccid5_hc_tx_hystart_update(struct ccid5_hc_tx_sock *hc, u32 delay)
+{
+	if (!(hc->tx_found & hystart_detect)) {
+		u32 curr_jiffies = jiffies;
+
+		/* first detection parameter - ack-train detection */
+		if (curr_jiffies - hc->tx_last_jiffies <= hystart_ack_delta) {
+			hc->tx_last_jiffies = curr_jiffies;
+			if (curr_jiffies - hc->tx_round_start >+					hc->tx_delay_min>>4)
+				hc->tx_found |= HYSTART_ACK_TRAIN;
+		}
+
+		/* obtain the minimum delay of more than sampling packets */
+		if (hc->tx_sample_cnt < HYSTART_MIN_SAMPLES) {
+			if (hc->tx_curr_rtt = 0 || hc->tx_curr_rtt > delay)
+				hc->tx_curr_rtt = delay;
+
+			hc->tx_sample_cnt++;
+		} else {
+			if (hc->tx_curr_rtt > hc->tx_delay_min +
+			    HYSTART_DELAY_THRESH(hc->tx_delay_min>>4))
+				hc->tx_found |= HYSTART_DELAY;
+		}
+		/*
+		 * Either one of two conditions are met,
+		 * we exit from slow start immediately.
+		 */
+		if (hc->tx_found & hystart_detect)
+			hc->tx_ssthresh = hc->tx_cwnd;
+	}
+}
+
+/* calculate the cubic root of x using a table lookup followed by one
+ * Newton-Raphson iteration.
+ * Avg err ~= 0.195%
+ */
+static u32 cubic_root(u64 a)
+{
+	u32 x, b, shift;
+	/*
+	 * cbrt(x) MSB values for x MSB values in [0..63].
+	 * Precomputed then refined by hand - Willy Tarreau
+	 *
+	 * For x in [0..63],
+	 *   v = cbrt(x << 18) - 1
+	 *   cbrt(x) = (v[x] + 10) >> 6
+	 */
+	static const u8 v[] = {
+		/* 0x00 */    0,   54,   54,   54,  118,  118,  118,  118,
+		/* 0x08 */  123,  129,  134,  138,  143,  147,  151,  156,
+		/* 0x10 */  157,  161,  164,  168,  170,  173,  176,  179,
+		/* 0x18 */  181,  185,  187,  190,  192,  194,  197,  199,
+		/* 0x20 */  200,  202,  204,  206,  209,  211,  213,  215,
+		/* 0x28 */  217,  219,  221,  222,  224,  225,  227,  229,
+		/* 0x30 */  231,  232,  234,  236,  237,  239,  240,  242,
+		/* 0x38 */  244,  245,  246,  248,  250,  251,  252,  254,
+	};
+
+	b = fls64(a);
+	if (b < 7) {
+		/* a in [0..63] */
+		return ((u32)v[(u32)a] + 35) >> 6;
+	}
+
+	b = ((b * 84) >> 8) - 1;
+	shift = (a >> (b * 3));
+
+	x = ((u32)(((u32)v[shift] + 10) << b)) >> 6;
+
+	/*
+	 * Newton-Raphson iteration
+	 *                         2
+	 * x    = ( 2 * x  +  a / x  ) / 3
+	 *  k+1          k         k
+	 */
+	x = (2 * x + (u32)div64_u64(a, (u64)x * (u64)(x - 1)));
+	x = ((x * 341) >> 10);
+	return x;
+}
+
+static inline void cubic_tcp_friendliness(struct ccid5_hc_tx_sock *hc)
+{
+	u32 delta, max_cnt;
+	u32 scale = beta_scale;
+	delta = (hc->tx_cwnd * scale) >> 3;
+	delta = delta ? delta : 1;
+	while (hc->tx_ack_cnt > delta) {		/* update cwnd */
+		hc->tx_ack_cnt -= delta;
+		hc->tcp_cwnd++;
+	}
+
+	if (hc->tcp_cwnd > hc->tx_cwnd) {	/* if bic is slower than tcp */
+		delta = hc->tcp_cwnd - hc->tx_cwnd;
+		delta = delta ? delta : 1;
+		max_cnt = hc->tx_cwnd / delta;
+		if (hc->tx_cnt > max_cnt)
+			hc->tx_cnt = max_cnt;
+	}
+
+	if (hc->tx_cnt = 0)			/* cannot be zero */
+		hc->tx_cnt = 1;
+}
+/*
+ * Compute congestion window to use.
+ */
+static inline void bictcp_update(struct ccid5_hc_tx_sock *hc)
+{
+	u64 offs;
+	u32 bic_target, delta, t;
+	hc->tx_ack_cnt++;	/* count the number of ACKs */
+
+	if (hc->tx_last_cwnd = hc->tx_cwnd &&
+	    (s32)(ccid5_time_stamp - hc->tx_last_time) <= HZ / 32)
+		return;
+
+	hc->tx_last_cwnd = hc->tx_cwnd;
+	hc->tx_last_time = ccid5_time_stamp;
+
+	if (hc->tx_epoch_start <= 0) {
+		/* record the beginning of an epoch */
+		hc->tx_epoch_start = ccid5_time_stamp;
+
+		if (hc->tx_last_max_cwnd >= hc->tx_cwnd) {
+			hc->tx_bic_K = 0;
+			hc->tx_bic_origin_point = hc->tx_cwnd;
+		} else {
+			/* Compute new K based on
+			 * (wmax-cwnd) * (srtt>>3 / HZ) / c * 2^(3*bictcp_HZ)
+			 */
+			hc->tx_bic_K = cubic_root(cube_factor
+			       * (hc->tx_last_max_cwnd - hc->tx_cwnd));
+			hc->tx_bic_origin_point = hc->tx_last_max_cwnd;
+		}
+		hc->tx_ack_cnt = 1;
+		hc->tcp_cwnd = hc->tx_cwnd;
+	}
+
+	/* cubic function - hclc*/
+	/* hclculate c * time^3 / rtt,
+	 *  while considering overflow in hclculation of time^3
+	 * (so time^3 is done by using 64 bit)
+	 * and without the support of division of 64bit numbers
+	 * (so all divisions are done by using 32 bit)
+	 *  also NOTE the unit of those veriables
+	 *	  time  = (t - K) / 2^bictcp_HZ
+	 *	  c = bic_shctxle >> 10
+	 * rtt  = (srtt >> 3) / HZ
+	 * !!! The following code does not have overflow problems,
+	 * if the cwnd < 1 million packets !!!
+	 */
+
+	/* change the unit from HZ to bictcp_HZ */
+	t = ((ccid5_time_stamp + (hc->tx_delay_min>>3)
+				- hc->tx_epoch_start) << CUBIC_DCCP_HZ) / HZ;
+	/*t = ccid5_time_stamp + hc->tx_delay_min - hc->tx_epoch_start;*/
+
+
+	if (t < hc->tx_bic_K)		/* t - K */
+		offs = hc->tx_bic_K - t;
+	else
+		offs = t - hc->tx_bic_K;
+
+	/* c/rtt * (t-K)^3 */
+	delta = (cube_rtt_scale * offs * offs * offs)
+		>> (10+3*CUBIC_DCCP_HZ);
+	if (t < hc->tx_bic_K) /* below origin*/
+		bic_target = hc->tx_bic_origin_point - delta;
+	else    /* above origin*/
+		bic_target = hc->tx_bic_origin_point + delta;
+
+	/* cubic function - calc bictcp_cnt*/
+	if (bic_target > hc->tx_cwnd)
+		hc->tx_cnt = hc->tx_cwnd / (bic_target - hc->tx_cwnd);
+	else
+		hc->tx_cnt = 100 * hc->tx_cwnd; /* very small increment*/
+
+	/*
+	* The initial growth of cubic function may be too conservative
+	* when the available bandwidth is still unknown.
+	*/
+	if (hc->tx_loss_cwnd = 0 && hc->tx_cnt > 20)
+		hc->tx_cnt = 20;   /* increase cwnd 5% per RTT */
+
+
+	/* TCP Friendly */
+	if (tcp_friendliness)
+		cubic_tcp_friendliness(hc);
+}
+
+static int ccid5_hc_tx_alloc_seq(struct ccid5_hc_tx_sock *hc)
+{
+	struct ccid5_seq *seqp;
+	int i;
+
+	/* check if we have space to preserve the pointer to the buffer */
+	if (hc->tx_seqbufc >= (sizeof(hc->tx_seqbuf) /
+			       sizeof(struct ccid5_seq *)))
+		return -ENOMEM;
+
+	/* allocate buffer and initialize linked list */
+	seqp = kmalloc(CCID5_SEQBUF_LEN * sizeof(struct ccid5_seq), gfp_any());
+	if (seqp = NULL)
+		return -ENOMEM;
+
+	for (i = 0; i < (CCID5_SEQBUF_LEN - 1); i++) {
+		seqp[i].ccid5s_next = &seqp[i + 1];
+		seqp[i + 1].ccid5s_prev = &seqp[i];
+	}
+	seqp[CCID5_SEQBUF_LEN - 1].ccid5s_next = seqp;
+	seqp->ccid5s_prev = &seqp[CCID5_SEQBUF_LEN - 1];
+
+	/* This is the first allocation.  Initiate the head and tail.  */
+	if (hc->tx_seqbufc = 0)
+		hc->tx_seqh = hc->tx_seqt = seqp;
+	else {
+		/* link the existing list with the one we just created */
+		hc->tx_seqh->ccid5s_next = seqp;
+		seqp->ccid5s_prev = hc->tx_seqh;
+
+		hc->tx_seqt->ccid5s_prev = &seqp[CCID5_SEQBUF_LEN - 1];
+		seqp[CCID5_SEQBUF_LEN - 1].ccid5s_next = hc->tx_seqt;
+	}
+
+	/* store the original pointer to the buffer so we can free it */
+	hc->tx_seqbuf[hc->tx_seqbufc] = seqp;
+	hc->tx_seqbufc++;
+
+	return 0;
+}
+
+static int ccid5_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
+{
+	if (ccid5_cwnd_network_limited(ccid5_hc_tx_sk(sk)))
+		return CCID_PACKET_WILL_DEQUEUE_LATER;
+	return CCID_PACKET_SEND_AT_ONCE;
+}
+
+static void ccid5_change_l_ack_ratio(struct sock *sk, u32 val)
+{
+	u32 max_ratio = DIV_ROUND_UP(ccid5_hc_tx_sk(sk)->tx_cwnd, 2);
+
+	/*
+	 * Ensure that Ack Ratio does not exceed ceil(cwnd/2), which is (2) from
+	 * RFC 4341, 6.1.2. We ignore the statement that Ack Ratio 2 is always
+	 * acceptable since this causes starvation/deadlock whenever cwnd < 2.
+	 * The same problem arises when Ack Ratio is 0 (ie. Ack Ratio disabled).
+	 */
+	if (val = 0 || val > max_ratio) {
+		DCCP_WARN("Limiting Ack Ratio (%u) to %u\n", val, max_ratio);
+		val = max_ratio;
+	}
+	dccp_feat_signal_nn_change(sk, DCCPF_ACK_RATIO,
+				   min_t(u32, val, DCCPF_ACK_RATIO_MAX));
+}
+
+static void ccid5_check_l_ack_ratio(struct sock *sk)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+
+	/*
+	 * After a loss, idle period, application limited period, or RTO we
+	 * need to check that the ack ratio is still less than the congestion
+	 * window. Otherwise, we will send an entire congestion window of
+	 * packets and got no response because we haven't sent ack ratio
+	 * packets yet.
+	 * If the ack ratio does need to be reduced, we reduce it to half of
+	 * the congestion window (or 1 if that's zero) instead of to the
+	 * congestion window. This prevents problems if one ack is lost.
+	 */
+	if (dccp_feat_nn_get(sk, DCCPF_ACK_RATIO) > hc->tx_cwnd)
+		ccid5_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
+}
+
+static void ccid5_change_l_seq_window(struct sock *sk, u64 val)
+{
+	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW,
+				   clamp_val(val, DCCPF_SEQ_WMIN,
+						  DCCPF_SEQ_WMAX));
+}
+
+static void ccid5_hc_tx_rto_expire(unsigned long data)
+{
+	struct sock *sk = (struct sock *)data;
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+	const bool sender_was_blocked = ccid5_cwnd_network_limited(hc);
+
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk)) {
+		sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + HZ / 5);
+		goto out;
+	}
+
+	ccid5_pr_debug("RTO_EXPIRE\n");
+
+	/* back-off timer */
+	hc->tx_rto <<= 1;
+	if (hc->tx_rto > DCCP_RTO_MAX)
+		hc->tx_rto = DCCP_RTO_MAX;
+
+	/* adjust pipe, cwnd etc */
+	hc->tx_ssthresh = hc->tx_cwnd / 2;
+	if (hc->tx_ssthresh < 2)
+		hc->tx_ssthresh = 2;
+
+	/* clear state about stuff we sent */
+	hc->tx_seqt = hc->tx_seqh;
+	hc->tx_packets_acked = 0;
+
+	/* clear ack ratio state. */
+	hc->tx_rpseq    = 0;
+	hc->tx_rpdupack = -1;
+	ccid5_change_l_ack_ratio(sk, 1);
+
+	/* if we were blocked before, we may now send cwnd=1 packet */
+	if (sender_was_blocked)
+		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
+	/* restart backed-off timer */
+	sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
+	bictcp_reset(hc);
+out:
+	bh_unlock_sock(sk);
+	sock_put(sk);
+}
+
+/*
+ *	Congestion window validation (RFC 2861).
+ */
+static int ccid5_do_cwv = 1;
+module_param(ccid5_do_cwv, bool, 0644);
+MODULE_PARM_DESC(ccid5_do_cwv, "Perform RFC2861 Congestion Window Validation");
+
+/**
+ * ccid5_update_used_window  -  Track how much of cwnd is actually used
+ * This is done in addition to CWV. The sender needs to have an idea
of how many
+ * packets may be in flight, to set the local Sequence Window value accordingly
+ * (RFC 4340, 7.5.2). The CWV mechanism is exploited to keep track of the
+ * maximum-used window. We use an EWMA low-pass filter to filter out noise.
+ */
+static void ccid5_update_used_window(struct ccid5_hc_tx_sock *hc, u32 new_wnd)
+{
+	hc->tx_expected_wnd = (3 * hc->tx_expected_wnd + new_wnd) / 4;
+}
+
+/* This borrows the code of tcp_cwnd_application_limited() */
+static void ccid5_cwnd_application_limited(struct sock *sk, const u32 now)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+	/* don't reduce cwnd below the initial window (IW) */
+	u32 init_win = rfc3390_bytes_to_packets(dccp_sk(sk)->dccps_mss_cache),
+	    win_used = max(hc->tx_cwnd_used, init_win);
+
+	if (win_used < hc->tx_cwnd) {
+		hc->tx_ssthresh = max(hc->tx_ssthresh,
+				     (hc->tx_cwnd >> 1) + (hc->tx_cwnd >> 2));
+		hc->tx_cwnd = (hc->tx_cwnd + win_used) >> 1;
+	}
+	hc->tx_cwnd_used  = 0;
+	hc->tx_cwnd_stamp = now;
+
+	ccid5_check_l_ack_ratio(sk);
+}
+
+/* This borrows the code of tcp_cwnd_restart() */
+static void ccid5_cwnd_restart(struct sock *sk, const u32 now)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+	u32 cwnd = hc->tx_cwnd, restart_cwnd,
+	    iwnd = rfc3390_bytes_to_packets(dccp_sk(sk)->dccps_mss_cache);
+
+	hc->tx_ssthresh = max(hc->tx_ssthresh, (cwnd >> 1) + (cwnd >> 2));
+
+	/* don't reduce cwnd below the initial window (IW) */
+	restart_cwnd = min(cwnd, iwnd);
+	cwnd >>= (now - hc->tx_lsndtime) / hc->tx_rto;
+	hc->tx_cwnd = max(cwnd, restart_cwnd);
+
+	hc->tx_cwnd_stamp = now;
+	hc->tx_cwnd_used  = 0;
+
+	ccid5_check_l_ack_ratio(sk);
+}
+
+static void ccid5_hc_tx_packet_sent(struct sock *sk, unsigned int len)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+	const u32 now = ccid5_time_stamp;
+	struct ccid5_seq *next;
+
+	/* slow-start after idle periods (RFC 2581, RFC 2861) */
+	if (ccid5_do_cwv && !hc->tx_pipe &&
+	    (s32)(now - hc->tx_lsndtime) >= hc->tx_rto)
+		ccid5_cwnd_restart(sk, now);
+
+	hc->tx_lsndtime = now;
+	hc->tx_pipe++;
+
+	/* see whether cwnd was fully used (RFC 2861), update expected window */
+	if (ccid5_cwnd_network_limited(hc)) {
+		ccid5_update_used_window(hc, hc->tx_cwnd);
+		hc->tx_cwnd_used  = 0;
+		hc->tx_cwnd_stamp = now;
+	} else {
+		if (hc->tx_pipe > hc->tx_cwnd_used)
+			hc->tx_cwnd_used = hc->tx_pipe;
+
+		ccid5_update_used_window(hc, hc->tx_cwnd_used);
+
+		if (ccid5_do_cwv &&
+			(s32)(now - hc->tx_cwnd_stamp) >= hc->tx_rto)
+			ccid5_cwnd_application_limited(sk, now);
+	}
+
+	hc->tx_seqh->ccid5s_seq   = dp->dccps_gss;
+	hc->tx_seqh->ccid5s_acked = 0;
+	hc->tx_seqh->ccid5s_sent  = now;
+
+	next = hc->tx_seqh->ccid5s_next;
+	/* check if we need to alloc more space */
+	if (next = hc->tx_seqt) {
+		if (ccid5_hc_tx_alloc_seq(hc)) {
+			DCCP_CRIT("packet history - out of memory!");
+			/* FIXME: find a more graceful way to bail out */
+			return;
+		}
+		next = hc->tx_seqh->ccid5s_next;
+		BUG_ON(next = hc->tx_seqt);
+	}
+	hc->tx_seqh = next;
+
+	ccid5_pr_debug("cwnd=%d pipe=%d\n", hc->tx_cwnd, hc->tx_pipe);
+
+	sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
+
+#ifdef CONFIG_IP_DCCP_CCID5_DEBUG
+	do {
+		struct ccid5_seq *seqp = hc->tx_seqt;
+
+		while (seqp != hc->tx_seqh) {
+			ccid5_pr_debug("out seq=%llu acked=%d time=%u\n",
+				       (unsigned long long)seqp->ccid5s_seq,
+				       seqp->ccid5s_acked, seqp->ccid5s_sent);
+			seqp = seqp->ccid5s_next;
+		}
+	} while (0);
+	ccid5_pr_debug("=====\n");
+#endif
+}
+
+static size_t ccid5_hc_tx_probe(struct sock *sk, char *buf, const
size_t maxlen)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+
+	/* Specific field numbering:
+			5     6    7      8        9      10     11
+			rto   rtt  mdev   rttvar   cwnd   pipe   ssthresh  */
+	return snprintf(buf, maxlen, " %u %u %u %u %u %u %u", hc->tx_rto,
+			hc->tx_srtt >> 3, hc->tx_mdev >> 2, hc->tx_rttvar >> 2,
+			hc->tx_cwnd, hc->tx_pipe, hc->tx_ssthresh);
+
+}
+
+/**
+ * ccid5_rtt_estimator - This algorithm is based on ccid2_rtt_estimator
+ * Sample RTT and compute RTO using RFC2988 algorithm
+ * This code is almost identical with TCP's tcp_rtt_estimator(), since
+ * - it has a higher sampling frequency (recommended by RFC 1323),
+ * - the RTO does not collapse into RTT due to RTTVAR going towards zero,
+ * - it is simple (cf. more complex proposals such as Eifel timer or research
+ *   which suggests that the gain should be set according to window size),
+ * - in tests it was found to work well with CCID2 [gerrit].
+ */
+static void ccid5_rtt_estimator(struct sock *sk, const long mrtt)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+	long m = mrtt ? : 1;
+
+	if (hc->tx_srtt = 0) {
+		/* First measurement m */
+		hc->tx_srtt = m << 3;
+		hc->tx_mdev = m << 1;
+
+		hc->tx_mdev_max = max(hc->tx_mdev, tcp_rto_min(sk));
+		hc->tx_rttvar   = hc->tx_mdev_max;
+
+		hc->tx_rtt_seq  = dccp_sk(sk)->dccps_gss;
+	} else {
+		/* Update scaled SRTT as SRTT += 1/8 * (m - SRTT) */
+		m -= (hc->tx_srtt >> 3);
+		hc->tx_srtt += m;
+
+		/* Similarly, update scaled mdev with regard to |m| */
+		if (m < 0) {
+			m = -m;
+			m -= (hc->tx_mdev >> 2);
+			/*
+			 * This neutralises RTO increase when RTT < SRTT - mdev
+			 * (see P. Sarolahti, A. Kuznetsov,"Congestion Control
+			 * in Linux TCP", USENIX 2002, pp. 49-62).
+			 */
+			if (m > 0)
+				m >>= 3;
+		} else {
+			m -= (hc->tx_mdev >> 2);
+		}
+		hc->tx_mdev += m;
+
+		if (hc->tx_mdev > hc->tx_mdev_max) {
+			hc->tx_mdev_max = hc->tx_mdev;
+			if (hc->tx_mdev_max > hc->tx_rttvar)
+				hc->tx_rttvar = hc->tx_mdev_max;
+		}
+
+		/*
+		 * Decay RTTVAR at most once per flight, exploiting that
+		 *  1) pipe <= cwnd <= Sequence_Window = W  (RFC 4340, 7.5.2)
+		 *  2) AWL = GSS-W+1 <= GAR <= GSS          (RFC 4340, 7.5.1)
+		 * GAR is a useful bound for FlightSize = pipe.
+		 * AWL is probably too low here, as it over-estimates pipe.
+		 */
+		if (after48(dccp_sk(sk)->dccps_gar, hc->tx_rtt_seq)) {
+			if (hc->tx_mdev_max < hc->tx_rttvar)
+				hc->tx_rttvar -= (hc->tx_rttvar -
+						  hc->tx_mdev_max) >> 2;
+			hc->tx_rtt_seq  = dccp_sk(sk)->dccps_gss;
+			hc->tx_mdev_max = tcp_rto_min(sk);
+		}
+	}
+
+	/*
+	 * Set RTO from SRTT and RTTVAR
+	 * As in TCP, 4 * RTTVAR >= TCP_RTO_MIN, giving a minimum RTO of 200 ms.
+	 * This agrees with RFC 4341, 5:
+	 *	"Because DCCP does not retransmit data, DCCP does not require
+	 *	 TCP's recommended minimum timeout of one second".
+	 */
+	hc->tx_rto = (hc->tx_srtt >> 3) + hc->tx_rttvar;
+
+	if (hc->tx_rto > DCCP_RTO_MAX)
+		hc->tx_rto = DCCP_RTO_MAX;
+}
+
+static inline u32 rtt_estimation(struct ccid5_hc_tx_sock *hc)
+{
+	return hc->tx_srtt << 3;
+}
+
+/*
+ * Action to be executed on a new acked packet
+ */
+static inline void ccid5_new_ack(struct sock *sk,
+				 struct ccid5_seq *seqp)
+{
+	u32 current_rtt, delay;
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+	struct dccp_sock *dp = dccp_sk(sk);
+	int r_seq_used = hc->tx_cwnd / dp->dccps_l_ack_ratio;
+
+	/*
+	 * Let's update the RTT estimation.
+	 * This algorithm is a copy of ccid2_rtt_estimator function. So, it
+	 * inherit all goodness and problems
+	 */
+	ccid5_rtt_estimator(sk, ccid5_time_stamp - seqp->ccid5s_sent);
+
+
+	current_rtt = rtt_estimation(hc);
+
+	hc->tx_delay_min = hc->tx_delay_min ?
+		min(hc->tx_delay_min, current_rtt) : current_rtt;
+
+	if (hc->tx_cwnd <= hc->tx_ssthresh) {
+		hc->tx_cwnd++;
+		/*COMMENT  Issue to be discussed*/
+		if (hystart /*&& after(ack, ca->end_seq)*/)
+			ccid5_hc_tx_hystart_reset(hc);
+	} else {
+		bictcp_update(hc);
+		if (hc->tx_cwnd_cnt > hc->tx_cnt) {
+			hc->tx_cwnd++;
+			hc->tx_cwnd_cnt = 0;
+		} else
+			hc->tx_cwnd_cnt++;
+	}
+
+	/*
+	 * Adjust the local sequence window and the ack ratio to allow about
+	 * 5 times the number of packets in the aindanetwork (RFC 4340 7.5.2)
+	 */
+	if (r_seq_used * CCID5_WIN_CHANGE_FACTOR >= dp->dccps_r_seq_win)
+		ccid5_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio * 2);
+	else if (r_seq_used * CCID5_WIN_CHANGE_FACTOR < dp->dccps_r_seq_win/2)
+		ccid5_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio / 2 ? : 1U);
+
+	if (hc->tx_cwnd * CCID5_WIN_CHANGE_FACTOR >= dp->dccps_l_seq_win)
+		ccid5_change_l_seq_window(sk, dp->dccps_l_seq_win * 2);
+	else if (hc->tx_cwnd * CCID5_WIN_CHANGE_FACTOR < dp->dccps_l_seq_win/2)
+		ccid5_change_l_seq_window(sk, dp->dccps_l_seq_win / 2);
+
+	ccid5_rtt_estimator(sk, ccid5_time_stamp - seqp->ccid5s_sent);
+
+	/*Hystart code*/
+
+	/* Discard delay samples right after fast recovery */
+	if ((s32)(ccid5_time_stamp - hc->tx_epoch_start) < HZ)
+		return;
+
+	delay = current_rtt << 3;
+	if (delay = 0)
+		delay = 1;
+
+	/* first time call or link delay decreases */
+	if (hc->tx_delay_min = 0 || hc->tx_delay_min > delay)
+		hc->tx_delay_min = delay;
+
+	/* hystart triggers when cwnd is larger than some threshold */
+	if (hystart && hc->tx_cwnd <= hc->tx_ssthresh &&
+	    hc->tx_cwnd >= hystart_low_window)
+		ccid5_hc_tx_hystart_update(hc, delay);
+
+}
+
+/*
+ * Action to be executed on congestion events
+ */
+static void ccid5_congestion_event(struct sock *sk, struct ccid5_seq *seqp)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+
+	if ((s32)(seqp->ccid5s_sent - hc->tx_last_cong) < 0) {
+		ccid5_pr_debug("Multiple losses in an RTT---treating as one\n");
+		return;
+	}
+
+	hc->tx_last_cong = ccid5_time_stamp;
+
+
+	hc->tx_epoch_start = 0;	/* end of epoch */
+
+	/* Wmax and fast convergence */
+	if (hc->tx_cwnd < hc->tx_last_max_cwnd && fast_convergence)
+		hc->tx_last_max_cwnd +			(hc->tx_cwnd * (BICTCP_BETA_SCALE + beta))
+			/ (2 * BICTCP_BETA_SCALE);
+	else
+		hc->tx_last_max_cwnd = hc->tx_cwnd;
+
+	hc->tx_loss_cwnd = hc->tx_cwnd;
+
+	hc->tx_ssthresh = hc->tx_cwnd +		max((hc->tx_cwnd * beta) / BICTCP_BETA_SCALE, 2U);
+	ccid5_check_l_ack_ratio(sk);
+}
+
+static int ccid5_hc_tx_parse_options(struct sock *sk, u8 packet_type,
+				     u8 option, u8 *optval, u8 optlen)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+
+	switch (option) {
+	case DCCPO_ACK_VECTOR_0:
+	case DCCPO_ACK_VECTOR_1:
+		return dccp_ackvec_parsed_add(&hc->tx_av_chunks, optval, optlen,
+					      option - DCCPO_ACK_VECTOR_0);
+	}
+	return 0;
+}
+
+static void ccid5_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+	const bool sender_was_blocked = ccid5_cwnd_network_limited(hc);
+	struct dccp_ackvec_parsed *avp;
+	u64 ackno, seqno;
+	struct ccid5_seq *seqp;
+	int done = 0;
+
+
+	/* check reverse path congestion */
+	seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+
+	/* XXX this whole "algorithm" is broken.  Need to fix it to keep track
+	 * of the seqnos of the dupacks so that rpseq and rpdupack are correct
+	 * -sorbo.
+	 */
+	/* need to bootstrap */
+	if (hc->tx_rpdupack = -1) {
+		hc->tx_rpdupack = 0;
+		hc->tx_rpseq    = seqno;
+	} else {
+		/* check if packet is consecutive */
+		if (dccp_delta_seqno(hc->tx_rpseq, seqno) = 1)
+			hc->tx_rpseq = seqno;
+		/* it's a later packet */
+		else if (after48(seqno, hc->tx_rpseq)) {
+			hc->tx_rpdupack++;
+
+			/* check if we got enough dupacks */
+			if (hc->tx_rpdupack >= NUMDUPACK) {
+				hc->tx_rpdupack = -1; /* XXX lame */
+				hc->tx_rpseq    = 0;
+#ifdef __CCID5_COPES_GRACEFULLY_WITH_ACK_CONGESTION_CONTROL__
+				/* TODO: It must be analized since the ack
+				 * mechanism for ack is the same of CCID2
+				 * FIXME: Ack Congestion Control is broken;
+				 * in the current state instabilities
+				 * occurred with Ack Ratios greater than 1;
+				 * causing hang-ups and long RTO timeouts.
+				 * This needs to be fixed before opening up
+				 * dynamic changes. -- gerrit
+				 */
+				ccid5_change_l_ack_ratio(dccp_sk(sk),
+						2 * dp->dccps_l_ack_ratio);
+#endif
+			}
+		}
+	}
+
+	/* check forward path congestion */
+	if (dccp_packet_without_ack(skb))
+		return;
+
+	/* still didn't send out new data packets */
+	if (hc->tx_seqh = hc->tx_seqt)
+		goto done;
+
+	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
+	if (after48(ackno, hc->tx_high_ack))
+		hc->tx_high_ack = ackno;
+
+	seqp = hc->tx_seqt;
+	while (before48(seqp->ccid5s_seq, ackno)) {
+		seqp = seqp->ccid5s_next;
+		if (seqp = hc->tx_seqh) {
+			seqp = hc->tx_seqh->ccid5s_prev;
+			break;
+		}
+	}
+
+	/* go through all ack vectors */
+	list_for_each_entry(avp, &hc->tx_av_chunks, node) {
+		/* go through this ack vector */
+		for (; avp->len--; avp->vec++) {
+			u64 ackno_end_rl = SUB48(ackno,
+						 dccp_ackvec_runlen(avp->vec));
+
+			ccid5_pr_debug("ackvec %llu |%u,%u|\n",
+				       (unsigned long long)ackno,
+				       dccp_ackvec_state(avp->vec) >> 6,
+				       dccp_ackvec_runlen(avp->vec));
+			/* if the seqno we are analyzing is larger than the
+			 * current ackno, then move towards the tail of our
+			 * seqnos.
+			 */
+			while (after48(seqp->ccid5s_seq, ackno)) {
+				if (seqp = hc->tx_seqt) {
+					done = 1;
+					break;
+				}
+				seqp = seqp->ccid5s_prev;
+			}
+			if (done)
+				break;
+
+			/* check all seqnos in the range of the vector
+			 * run length
+			 */
+			while (
+				between48(seqp->ccid5s_seq, ackno_end_rl, ackno)
+			      ) {
+				const u8 state = dccp_ackvec_state(avp->vec);
+
+				/* new packet received or marked */
+				if (state != DCCPAV_NOT_RECEIVED &&
+				    !seqp->ccid5s_acked) {
+					if (state = DCCPAV_ECN_MARKED)
+						ccid5_congestion_event(sk,
+								       seqp);
+					else
+						ccid5_new_ack(sk, seqp);
+
+					seqp->ccid5s_acked = 1;
+					ccid5_pr_debug("Got ack for %llu\n",
+						       (unsigned long long)
+						       seqp->ccid5s_seq);
+					hc->tx_pipe--;
+				}
+				if (seqp = hc->tx_seqt) {
+					done = 1;
+					break;
+				}
+				seqp = seqp->ccid5s_prev;
+			}
+			if (done)
+				break;
+
+			ackno = SUB48(ackno_end_rl, 1);
+		}
+		if (done)
+			break;
+	}
+
+	/* The state about what is acked should be correct now
+	 * Check for NUMDUPACK
+	 */
+	seqp = hc->tx_seqt;
+	while (before48(seqp->ccid5s_seq, hc->tx_high_ack)) {
+		seqp = seqp->ccid5s_next;
+		if (seqp = hc->tx_seqh) {
+			seqp = hc->tx_seqh->ccid5s_prev;
+			break;
+		}
+	}
+	done = 0;
+	while (1) {
+		if (seqp->ccid5s_acked) {
+			done++;
+			if (done = NUMDUPACK)
+				break;
+		}
+		if (seqp = hc->tx_seqt)
+			break;
+		seqp = seqp->ccid5s_prev;
+	}
+
+	/* If there are at least 3 acknowledgements, anything unacknowledged
+	 * below the last sequence number is considered lost
+	 */
+	if (done = NUMDUPACK) {
+		struct ccid5_seq *last_acked = seqp;
+
+		/* check for lost packets */
+		while (1) {
+			if (!seqp->ccid5s_acked) {
+				ccid5_pr_debug("Packet lost: %llu\n",
+					       (unsigned long long)
+					       seqp->ccid5s_seq);
+				/* XXX need to traverse from tail -> head in
+				 * order to detect multiple congestion events in
+				 * one ack vector.
+				 */
+				ccid5_congestion_event(sk, seqp);
+				hc->tx_pipe--;
+			}
+			if (seqp = hc->tx_seqt)
+				break;
+			seqp = seqp->ccid5s_prev;
+		}
+
+		hc->tx_seqt = last_acked;
+	}
+
+	/* trim acked packets in tail */
+	while (hc->tx_seqt != hc->tx_seqh) {
+		if (!hc->tx_seqt->ccid5s_acked)
+			break;
+
+		hc->tx_seqt = hc->tx_seqt->ccid5s_next;
+	}
+
+	/* restart RTO timer if not all outstanding data has been acked */
+	if (hc->tx_pipe = 0)
+		sk_stop_timer(sk, &hc->tx_rtotimer);
+	else
+		sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
+done:
+	/* check if incoming Acks allow pending packets to be sent */
+	if (sender_was_blocked && !ccid5_cwnd_network_limited(hc))
+		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
+	dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
+}
+
+static int ccid5_hc_tx_init(struct ccid *ccid, struct sock *sk)
+{
+	struct ccid5_hc_tx_sock *hc = ccid_priv(ccid);
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	u32 max_ratio;
+
+
+	/* Precompute a bunch of the scaling factors that are used per-packet
+	 * based on SRTT of 100ms
+	 */
+
+	beta_scale = 8*(BICTCP_BETA_SCALE+beta) / 3 /
+		(BICTCP_BETA_SCALE - beta);
+
+	cube_rtt_scale = (bic_scale * 10);	/* 1024*c/rtt */
+
+	/* calculate the "K" for (wmax-cwnd) = c/rtt * K^3
+	 *  so K = cubic_root( (wmax-cwnd)*rtt/c )
+	 * the unit of K is bictcp_HZ=2^10, not HZ
+	 *
+	 *  c = bic_scale >> 10
+	 *  rtt = 100ms
+	 *
+	 * the following code has been designed and tested for
+	 * cwnd < 1 million packets
+	 * RTT < 100 seconds
+	 * HZ < 1,000,00  (corresponding to 10 nano-second)
+	 */
+
+	/* 1/c * 2^2*CUBIC_DCCP_HZ * srtt */
+	cube_factor = 1ull << (10+3*CUBIC_DCCP_HZ); /* 2^40 */
+
+	/* divide by bic_scale and by constant Srtt (100ms) */
+	do_div(cube_factor, bic_scale * 10);
+
+
+	bictcp_reset(hc);
+
+	if (hystart)
+		ccid5_hc_tx_hystart_reset(hc);
+
+	hc->tx_ssthresh = ~0U; /*As same CCID-2*/
+
+	if (!hystart && initial_ssthresh)
+		hc->tx_ssthresh = initial_ssthresh;
+
+	/* Use larger initial windows (RFC 4341, section 5). */
+	hc->tx_cwnd = rfc3390_bytes_to_packets(dp->dccps_mss_cache);
+
+
+	/* Make sure that Ack Ratio is enabled and within bounds. */
+	max_ratio = DIV_ROUND_UP(hc->tx_cwnd, 2);
+	if (dp->dccps_l_ack_ratio = 0 || dp->dccps_l_ack_ratio > max_ratio)
+		dp->dccps_l_ack_ratio = max_ratio;
+
+	/* XXX init ~ to window size... */
+	if (ccid5_hc_tx_alloc_seq(hc))
+		return -ENOMEM;
+
+	hc->tx_rto	 = DCCP_TIMEOUT_INIT;
+	hc->tx_rpdupack  = -1;
+	hc->tx_last_cong = hc->tx_lsndtime +		hc->tx_cwnd_stamp = ccid5_time_stamp;
+	hc->tx_cwnd_used = 0;
+	setup_timer(&hc->tx_rtotimer, ccid5_hc_tx_rto_expire,
+			(unsigned long)sk);
+	INIT_LIST_HEAD(&hc->tx_av_chunks);
+	return 0;
+}
+
+static void ccid5_hc_tx_exit(struct sock *sk)
+{
+	struct ccid5_hc_tx_sock *hc = ccid5_hc_tx_sk(sk);
+	int i;
+
+	sk_stop_timer(sk, &hc->tx_rtotimer);
+
+	for (i = 0; i < hc->tx_seqbufc; i++)
+		kfree(hc->tx_seqbuf[i]);
+	hc->tx_seqbufc = 0;
+}
+
+static void ccid5_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct ccid5_hc_rx_sock *hc = ccid5_hc_rx_sk(sk);
+
+	if (!dccp_data_packet(skb))
+		return;
+
+	if (++hc->rx_num_data_pkts >= dccp_sk(sk)->dccps_r_ack_ratio) {
+		dccp_send_ack(sk);
+		hc->rx_num_data_pkts = 0;
+	}
+}
+
+struct ccid_operations ccid5_ops = {
+	.ccid_id		  = DCCPC_CCID_CUBIC,
+	.ccid_name		  = "Cubic-DCCP",
+	.ccid_hc_tx_obj_size	  = sizeof(struct ccid5_hc_tx_sock),
+	.ccid_hc_tx_init	  = ccid5_hc_tx_init,
+	.ccid_hc_tx_exit	  = ccid5_hc_tx_exit,
+	.ccid_hc_tx_send_packet	  = ccid5_hc_tx_send_packet,
+	.ccid_hc_tx_packet_sent	  = ccid5_hc_tx_packet_sent,
+	.ccid_hc_tx_probe	  = ccid5_hc_tx_probe,
+	.ccid_hc_tx_parse_options = ccid5_hc_tx_parse_options,
+	.ccid_hc_tx_packet_recv	  = ccid5_hc_tx_packet_recv,
+	.ccid_hc_rx_obj_size	  = sizeof(struct ccid5_hc_rx_sock),
+	.ccid_hc_rx_packet_recv	  = ccid5_hc_rx_packet_recv,
+};
+
+#ifdef CONFIG_IP_DCCP_CCID5_DEBUG
+module_param(ccid5_debug, bool, 0644);
+MODULE_PARM_DESC(ccid5_debug, "Enable CCID-5 debug messages");
+#endif
+
+
diff --git a/net/dccp/ccids/ccid5.h b/net/dccp/ccids/ccid5.h
new file mode 100644
index 0000000..e3a0250
--- /dev/null
+++ b/net/dccp/ccids/ccid5.h
@@ -0,0 +1,164 @@
+/*
+ *  Copyright (c) 2011   Federal University of Campina Grande, Paraiba, BR.
+ *
+ *  An implementation of the DCCP protocol
+ *
+ *  Copyright (c) 2011 Ivo Calado, Leandro Sales
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab. For further information
+ *  please see http://embeddedlab.org/
+ *  <ivocalado@ee.ufcg.edu.br> <leandroal@gmail.com>
+ *
+ *  This code is a version of the Cubic algorithm to the DCCP protocol.
+ *  Due to that, it copies as much code as possible from net/ipv4/tcp_cubic.c
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#ifndef _DCCP_CCID5_H_
+#define _DCCP_CCID5_H_
+
+#define NUMDUPACK	3
+
+/*
+ * CCID-5 timestamping faces the same issues as TCP timestamping.
+ * Hence we reuse/share as much of the code as possible.
+ */
+#define ccid5_time_stamp	tcp_time_stamp
+
+struct ccid5_seq {
+	u64			ccid5s_seq;
+	u32			ccid5s_sent;
+	int			ccid5s_acked;
+	struct ccid5_seq	*ccid5s_prev;
+	struct ccid5_seq	*ccid5s_next;
+};
+
+#define CCID5_SEQBUF_LEN 1024
+#define CCID5_SEQBUF_MAX 128
+
+/*
+ * Multiple of congestion window to keep the sequence window at
+ * (RFC 4340 7.5.2)
+ */
+#define CCID5_WIN_CHANGE_FACTOR 5
+
+struct ccid5_hc_tx_sock {
+
+	/* increase cwnd by 1 after ACKs */
+	u32			tx_cnt;
+	/* last maximum tx_cwnd */
+	u32			tx_last_max_cwnd;
+	/* congestion window at last loss */
+	u32			tx_loss_cwnd;
+	/* the last snd_cwnd */
+	u32			tx_last_cwnd;
+	/* time when updated tx_last_cwnd */
+	u32			tx_last_time;
+	/* origin point of bic function */
+	u32			tx_bic_origin_point;
+	/* time to origin point from the beginning of the current epoch */
+	u32			tx_bic_K;
+	/* min delay */
+	u32			tx_delay_min;
+	/* beginning of an epoch */
+	u32			tx_epoch_start;
+	/* number of acks */
+	u32			tx_ack_cnt;
+	/* estimated tcp cwnd */
+	u32			tcp_cwnd;
+	/* simulates tcp's cwnd */
+	u32			tx_cwnd;
+	/* simulates tcp's cwnd count */
+	u32			tx_cwnd_cnt;
+	/* slow start threshold */
+	u32			tx_ssthresh;
+	/* number of packets sent and not acked */
+	u32			tx_pipe;
+
+	/* Implementation of Hystart algorithm */
+	/* the exit point is found? */
+	u8			tx_found;
+	/* beginning of each round */
+	u32			tx_round_start;
+	/* last time when the ACK spacing is close */
+	u32			tx_last_jiffies;
+	/* the minimum rtt of current round */
+	u32			tx_curr_rtt;
+	/* number of samples to decide curr_rtt */
+	u8			tx_sample_cnt;
+
+
+	/* RTT measurement: variables/principles are the same as in TCP */
+	u32			tx_srtt,
+				tx_mdev,
+				tx_mdev_max,
+				tx_rttvar,
+				tx_rto;
+	u64			tx_rtt_seq:48;
+	struct timer_list	tx_rtotimer;
+
+	u64			tx_rpseq;
+	int			tx_rpdupack;
+	u32			tx_last_cong;
+	u64			tx_high_ack;
+	struct list_head	tx_av_chunks;
+
+	/* Congestion Window validation (optional, RFC 2861) */
+	u32			tx_cwnd_used,
+				tx_expected_wnd,
+				tx_cwnd_stamp,
+				tx_lsndtime;
+
+	u32			tx_packets_acked;
+	struct ccid5_seq	*tx_seqbuf[CCID5_SEQBUF_MAX];
+	int			tx_seqbufc;
+	struct ccid5_seq	*tx_seqh;
+	struct ccid5_seq	*tx_seqt;
+};
+
+/**
+ * struct ccid5_hc_rx_sock  -  Receiving end of CCID-2 half-connection
+ * @rx_num_data_pkts: number of data packets received since last feedback
+ */
+struct ccid5_hc_rx_sock {
+	u32	rx_num_data_pkts;
+};
+
+static inline bool ccid5_cwnd_network_limited(struct ccid5_hc_tx_sock *hc)
+{
+	return hc->tx_pipe >= hc->tx_cwnd;
+}
+
+/*
+ * Convert RFC 3390 larger initial window into an equivalent number of packets.
+ * This is based on the numbers specified in RFC 5681, 3.1.
+ */
+static inline u32 rfc3390_bytes_to_packets(const u32 smss)
+{
+	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
+}
+
+static inline struct ccid5_hc_tx_sock *ccid5_hc_tx_sk(const struct sock *sk)
+{
+	return ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
+}
+
+static inline struct ccid5_hc_rx_sock *ccid5_hc_rx_sk(const struct sock *sk)
+{
+	return ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
+}
+
+#endif /* _DCCP_CCID5_H_ */
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 18029de..69f212b 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -940,6 +940,30 @@ static const struct ccid_dependency
*dccp_feat_ccid_deps(u8 ccid, bool is_local)
 			{ 0, 0, 0, 0 }
 		}
 	};
+	static const struct ccid_dependency ccid5_dependencies[2][2] = {
+	/*
+	* CCID-5 is implemented with support ACK Vector as dependency,
+	* following the same structure of CCID-2
+	*/
+		{       /* Dependencies of the receiver-side (remote) CCID5 */
+			{
+				.dependent_feat = DCCPF_SEND_ACK_VECTOR,
+				.is_local       = true,
+				.is_mandatory   = true,
+				.val            = 1
+			},
+			{ 0, 0, 0, 0 }
+		},
+		{       /* Dependencies of the sender-side (local) CCID5 */
+			{
+				.dependent_feat = DCCPF_SEND_ACK_VECTOR,
+				.is_local       = false,
+				.is_mandatory   = true,
+				.val            = 1
+			},
+			{ 0, 0, 0, 0 }
+		}
+	};
 	switch (ccid) {
 	case DCCPC_CCID_ZERO:
 		return ccid0_dependencies[is_local];
@@ -948,6 +972,8 @@ static const struct ccid_dependency
*dccp_feat_ccid_deps(u8 ccid, bool is_local)
 	case DCCPC_CCID3:
 	case DCCPC_CCID4: /* fall through (CCID-4 is a variation of CCID-3 */
 		return ccid3_dependencies[is_local];
+	case DCCPC_CCID_CUBIC:
+		return ccid5_dependencies[is_local];
 	default:
 		return NULL;
 	}
-- 
1.7.6.1
