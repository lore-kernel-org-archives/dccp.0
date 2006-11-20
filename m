From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 20 Nov 2006 16:05:31 +0000
Subject: [PATCH 1/2] [RESENT]: DCCP Warning Message Scheme
Message-Id: <200611201605.31930@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]:  Simplified conditions due to use of enum:8 states

This reaps the benefit of the earlier patch, which changed the type of
CCID 3 states to use enums, in that many conditions are now simplified
and the number of possible (unexpected) values is greatly reduced.


[DCCP]: Introduce a consistent BUG/WARN message scheme

This refines the existing set of DCCP messages so that 
 * BUG(), BUG_ON(), WARN_ON() have meaningful DCCP-specific counterparts
 * DCCP_CRIT (for severe warnings) is not rate-limited
 * DCCP_WARN() is introduced as rate-limited wrapper

Using these allows a faster and cleaner transition to their original 
counterparts once the code has matured into a full DCCP implementation.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c                  |    5 -
 net/dccp/ccids/ccid2.c             |    2 
 net/dccp/ccids/ccid3.c             |  132 +++++++++++++++----------------------
 net/dccp/ccids/lib/loss_interval.c |    6 -
 net/dccp/ccids/lib/tfrc_equation.c |    7 +
 net/dccp/dccp.h                    |   17 +++-
 net/dccp/feat.c                    |   11 +--
 net/dccp/input.c                   |   25 +++----
 net/dccp/ipv4.c                    |   24 ++----
 net/dccp/ipv6.c                    |    4 -
 net/dccp/minisocks.c               |    7 -
 net/dccp/options.c                 |   10 +-
 net/dccp/output.c                  |   16 +---
 net/dccp/proto.c                   |    5 -
 14 files changed, 115 insertions(+), 156 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -491,9 +491,6 @@ u64 dccp_ackvec_parse(struct sock *sk, u
 					       sk, ackno, len, value);
 }
 
-static char dccp_ackvec_slab_msg[] __initdata -	KERN_CRIT "DCCP: Unable to create ack vectors slab caches\n";
-
 int __init dccp_ackvec_init(void)
 {
 	dccp_ackvec_slab = kmem_cache_create("dccp_ackvec",
@@ -515,7 +512,7 @@ out_destroy_slab:
 	kmem_cache_destroy(dccp_ackvec_slab);
 	dccp_ackvec_slab = NULL;
 out_err:
-	printk(dccp_ackvec_slab_msg);
+	DCCP_CRIT("Unable to create Ack Vector slab cache");
 	return -ENOBUFS;
 }
 
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -420,7 +420,7 @@ static int ccid2_ackvector(struct sock *
 	return -1;
 
 out_invalid_option:
-	BUG_ON(1); /* should never happen... options were previously parsed ! */
+	DCCP_BUG("Invalid option - this should not happen (previous parsing)!");
 	return -1;
 }
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -176,8 +176,6 @@ static void ccid3_hc_tx_no_feedback_time
 		       ccid3_tx_state_name(hctx->ccid3hctx_state));
 	
 	switch (hctx->ccid3hctx_state) {
-	case TFRC_SSTATE_TERM:
-		goto out;
 	case TFRC_SSTATE_NO_FBACK:
 		/* Halve send rate */
 		hctx->ccid3hctx_x /= 2;
@@ -240,9 +238,10 @@ static void ccid3_hc_tx_no_feedback_time
 					2 * usecs_div(hctx->ccid3hctx_s,
 						      hctx->ccid3hctx_x));
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hctx->ccid3hctx_state);
+	case TFRC_SSTATE_NO_SENT:
+		DCCP_BUG("Illegal %s state NO_SENT, sk=%p", dccp_role(sk), sk);
+		/* fall through */
+	case TFRC_SSTATE_TERM:
 		goto out;
 	}
 
@@ -264,7 +263,7 @@ static int ccid3_hc_tx_send_packet(struc
 	long delay;
 	int rc = -ENOTCONN;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	/* Check if pure ACK or Terminating*/
 	/*
@@ -282,9 +281,8 @@ static int ccid3_hc_tx_send_packet(struc
 
 		rc = -ENOBUFS;
 		if (unlikely(new_packet = NULL)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, not enough "
-				       "mem to add to history, send refused\n",
-				       __FUNCTION__, dccp_role(sk), sk);
+			DCCP_WARN("%s, sk=%p, not enough mem to add to history,"
+				  "send refused\n", dccp_role(sk), sk);
 			goto out;
 		}
 
@@ -317,9 +315,8 @@ static int ccid3_hc_tx_send_packet(struc
 		/* divide by -1000 is to convert to ms and get sign right */
 		rc = delay > 0 ? delay : 0;
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hctx->ccid3hctx_state);
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		rc = -EINVAL;
 		break;
 	}
@@ -343,7 +340,7 @@ static void ccid3_hc_tx_packet_sent(stru
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	dccp_timestamp(sk, &now);
 
@@ -354,13 +351,11 @@ static void ccid3_hc_tx_packet_sent(stru
 
 		packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
 		if (unlikely(packet = NULL)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: packet doesn't "
-				       "exists in history!\n", __FUNCTION__);
+			DCCP_WARN("packet doesn't exist in history!\n");
 			return;
 		}
 		if (unlikely(packet->dccphtx_sent)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: no unsent packet in "
-				       "history!\n", __FUNCTION__);
+			DCCP_WARN("no unsent packet in history!\n");
 			return;
 		}
 		packet->dccphtx_tstamp = now;
@@ -395,9 +390,8 @@ static void ccid3_hc_tx_packet_sent(stru
 	case TFRC_SSTATE_NO_SENT:
 		/* if first wasn't pure ack */
 		if (len != 0)
-			printk(KERN_CRIT "%s: %s, First packet sent is noted "
-					 "as a data packet\n",
-			       __FUNCTION__, dccp_role(sk));
+			DCCP_CRIT("%s, First packet sent is noted "
+				  "as a data packet",  dccp_role(sk));
 		return;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
@@ -410,9 +404,8 @@ static void ccid3_hc_tx_packet_sent(stru
 					  hctx->ccid3hctx_t_ipi);
 		}
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hctx->ccid3hctx_state);
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		break;
 	}
 }
@@ -430,7 +423,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	u32 x_recv;
 	u32 r_sample;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	/* we are only interested in ACKs */
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
@@ -455,11 +448,10 @@ static void ccid3_hc_tx_packet_recv(stru
 		packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
 						 DCCP_SKB_CB(skb)->dccpd_ack_seq);
 		if (unlikely(packet = NULL)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, seqno "
-				       "%llu(%s) does't exist in history!\n",
-				       __FUNCTION__, dccp_role(sk), sk,
+			DCCP_WARN("%s, sk=%p, seqno %llu(%s) does't exist "
+				  "in history!\n",  dccp_role(sk), sk,
 			    (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
-				dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
+				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
 			return;
 		}
 
@@ -467,9 +459,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		dccp_timestamp(sk, &now);
 		r_sample = timeval_delta(&now, &packet->dccphtx_tstamp);
 		if (unlikely(r_sample <= t_elapsed))
-			LIMIT_NETDEBUG(KERN_WARNING "%s: r_sample=%uus, "
-				       "t_elapsed=%uus\n",
-				       __FUNCTION__, r_sample, t_elapsed);
+			DCCP_WARN("r_sample=%uus,t_elapsed=%uus\n",
+				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
 
@@ -554,9 +545,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* set idle flag */
 		hctx->ccid3hctx_idle = 1;   
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hctx->ccid3hctx_state);
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		break;
 	}
 }
@@ -596,9 +586,9 @@ static int ccid3_hc_tx_parse_options(str
 	switch (option) {
 	case TFRC_OPT_LOSS_EVENT_RATE:
 		if (unlikely(len != 4)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, invalid "
-				       "len for TFRC_OPT_LOSS_EVENT_RATE\n",
-				       __FUNCTION__, dccp_role(sk), sk);
+			DCCP_WARN("%s, sk=%p, invalid len %d "
+				  "for TFRC_OPT_LOSS_EVENT_RATE\n",
+				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
 			opt_recv->ccid3or_loss_event_rate = ntohl(*(__be32 *)value);
@@ -617,9 +607,9 @@ static int ccid3_hc_tx_parse_options(str
 		break;
 	case TFRC_OPT_RECEIVE_RATE:
 		if (unlikely(len != 4)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, invalid "
-				       "len for TFRC_OPT_RECEIVE_RATE\n",
-				       __FUNCTION__, dccp_role(sk), sk);
+			DCCP_WARN("%s, sk=%p, invalid len %d "
+				  "for TFRC_OPT_RECEIVE_RATE\n",
+				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
 			opt_recv->ccid3or_receive_rate = ntohl(*(__be32 *)value);
@@ -722,17 +712,15 @@ static void ccid3_hc_rx_send_feedback(st
 						   delta);
 	}
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hcrx->ccid3hcrx_state);
+	case TFRC_RSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		return;
 	}
 
 	packet = dccp_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
 	if (unlikely(packet = NULL)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, no data packet "
-			       "in history!\n",
-			       __FUNCTION__, dccp_role(sk), sk);
+		DCCP_WARN("%s, sk=%p, no data packet in history!\n",
+			  dccp_role(sk), sk);
 		return;
 	}
 
@@ -820,29 +808,29 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	}
 
 	if (unlikely(step = 0)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, packet history "
-			       "contains no data packets!\n",
-			       __FUNCTION__, dccp_role(sk), sk);
+		DCCP_WARN("%s, sk=%p, packet history has no data packets!\n",
+			  dccp_role(sk), sk);
 		return ~0;
 	}
 
 	if (unlikely(interval = 0)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, Could not find a "
-			       "win_count interval > 0. Defaulting to 1\n",
-			       __FUNCTION__, dccp_role(sk), sk);
+		DCCP_WARN("%s, sk=%p, Could not find a win_count interval > 0."
+			  "Defaulting to 1\n", dccp_role(sk), sk);
 		interval = 1;
 	}
 found:
 	if (!tail) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: tail is null\n",
-		   __FUNCTION__);
+		DCCP_CRIT("tail is null\n");
 		return ~0;
 	}
 	rtt = timeval_delta(&tstamp, &tail->dccphrx_tstamp) * 4 / interval;
 	ccid3_pr_debug("%s, sk=%p, approximated RTT to %uus\n",
 		       dccp_role(sk), sk, rtt);
-	if (rtt = 0)
-		rtt = 1;
+
+	if (rtt = 0) {
+		DCCP_WARN("RTT=0, setting to 1\n");
+ 		rtt = 1;
+	}
 
 	dccp_timestamp(sk, &tstamp);
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
@@ -856,9 +844,7 @@ found:
 	tmp2 = (u32)tmp1;
 
 	if (!tmp2) {
-		LIMIT_NETDEBUG(KERN_WARNING "tmp2 = 0 "
-		   "%s: x_recv = %u, rtt =%u\n",
-		   __FUNCTION__, x_recv, rtt);
+		DCCP_CRIT("tmp2 = 0, x_recv = %u, rtt =%u\n", x_recv, rtt);
 		return ~0;
 	}
 
@@ -904,8 +890,7 @@ static void ccid3_hc_rx_update_li(struct
 		entry = dccp_li_hist_entry_new(ccid3_li_hist, SLAB_ATOMIC);
 
 		if (entry = NULL) {
-			printk(KERN_CRIT "%s: out of memory\n",__FUNCTION__);
-			dump_stack();
+			DCCP_BUG("out of memory - can not allocate entry");
 			return;
 		}
 
@@ -984,9 +969,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
 	int loss;
 
-	BUG_ON(hcrx = NULL ||
-	       !(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA ||
-		 hcrx->ccid3hcrx_state = TFRC_RSTATE_DATA));
+	BUG_ON(hcrx = NULL);
 
 	opt_recv = &dccp_sk(sk)->dccps_options_received;
 
@@ -1004,9 +987,8 @@ static void ccid3_hc_rx_packet_recv(stru
 		t_elapsed = opt_recv->dccpor_elapsed_time * 10;
 
 		if (unlikely(r_sample <= t_elapsed))
-			LIMIT_NETDEBUG(KERN_WARNING "%s: r_sample=%uus, "
-				       "t_elapsed=%uus\n",
-				       __FUNCTION__, r_sample, t_elapsed);
+			DCCP_WARN("r_sample=%uus, t_elapsed=%uus\n",
+				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
 
@@ -1030,9 +1012,8 @@ static void ccid3_hc_rx_packet_recv(stru
 	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, opt_recv->dccpor_ndp,
 					skb, SLAB_ATOMIC);
 	if (unlikely(packet = NULL)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, Not enough mem to "
-				"add rx packet to history, consider it lost!\n",
-			       __FUNCTION__, dccp_role(sk), sk);
+		DCCP_WARN("%s, sk=%p, Not enough mem to add rx packet "
+			  "to history, consider it lost!\n", dccp_role(sk), sk);
 		return;
 	}
 
@@ -1065,9 +1046,8 @@ static void ccid3_hc_rx_packet_recv(stru
 			ccid3_hc_rx_send_feedback(sk);
 		}
 		return;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!",  dccp_role(sk), sk,
-			 hcrx->ccid3hcrx_state);
+	case TFRC_RSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		return;
 	}
 
@@ -1084,10 +1064,8 @@ static void ccid3_hc_rx_packet_recv(stru
 		/* Scaling up by 1000000 as fixed decimal */
 		if (i_mean != 0)
 			hcrx->ccid3hcrx_p = 1000000 / i_mean;
-	} else {
-		printk(KERN_CRIT "%s: empty loss hist\n",__FUNCTION__);
-		dump_stack();
-	}
+	} else
+		DCCP_BUG("empty loss history");
 
 	if (hcrx->ccid3hcrx_p > p_prev) {
 		ccid3_hc_rx_send_feedback(sk);
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -13,7 +13,7 @@
 
 #include <linux/module.h>
 #include <net/sock.h>
-
+#include "../../dccp.h"
 #include "loss_interval.h"
 
 struct dccp_li_hist *dccp_li_hist_new(const char *name)
@@ -109,7 +109,7 @@ u32 dccp_li_hist_calc_i_mean(struct list
 	i_tot = max(i_tot0, i_tot1);
 
 	if (!w_tot) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: w_tot = 0\n", __FUNCTION__);
+		DCCP_WARN("w_tot = 0\n");
 		return 1;
 	}
 
@@ -128,7 +128,7 @@ int dccp_li_hist_interval_new(struct dcc
 		entry = dccp_li_hist_entry_new(hist, SLAB_ATOMIC);
 		if (entry = NULL) {
 			dccp_li_hist_purge(hist, list);
-			dump_stack();
+			DCCP_BUG("loss interval list entry is NULL");
 			return 0;
 		}
 		entry->dccplih_interval = ~0;
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -13,9 +13,8 @@
  */
 
 #include <linux/module.h>
-
 #include <asm/div64.h>
-
+#include "../../dccp.h"
 #include "tfrc.h"
 
 #define TFRC_CALC_X_ARRSIZE 500
@@ -588,8 +587,10 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 		/* p should be 0 unless there is a bug in my code */
 		index = 0;
 
-	if (R = 0)
+	if (R = 0) {
+		DCCP_WARN("RTT=0, setting to 1\n");
 		R = 1; /* RTT can't be zero or else divide by zero */
+	}
 
 	BUG_ON(index >= TFRC_CALC_X_ARRSIZE);
 
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -18,12 +18,17 @@
 #include <net/tcp.h>
 #include "ackvec.h"
 
-#define DCCP_CRIT(fmt, a...) LIMIT_NETDEBUG(KERN_CRIT fmt " at %s:%d/%s()\n",  \
- 					 ##a, __FILE__, __LINE__, __FUNCTION__)
-#define DCCP_BUG(fmt, a...)  do { DCCP_CRIT(fmt, ##a); dump_stack(); } while (0)
-#define DCCP_BUG_ON(cond)    do { if (unlikely((cond) = 0))                   \
-					DCCP_BUG("BUG: condition \"%s\" fails",\
-						 __stringify((cond)));	       \
+/*
+ * 	DCCP - specific warning and debugging macros.
+ */
+#define DCCP_WARN(fmt, a...) LIMIT_NETDEBUG(KERN_WARNING "%s: " fmt,       \
+						        __FUNCTION__, ##a)
+#define DCCP_CRIT(fmt, a...) printk(KERN_CRIT fmt " at %s:%d/%s()\n", ##a, \
+					 __FILE__, __LINE__, __FUNCTION__)
+#define DCCP_BUG(a...)       do { DCCP_CRIT("BUG: " a); dump_stack(); } while(0)
+#define DCCP_BUG_ON(cond)    do { if (unlikely((cond) != 0))		   \
+				     DCCP_BUG("\"%s\" holds (exception!)", \
+					      __stringify(cond));          \
 			     } while (0)
 
 #ifdef MODULE
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -25,11 +25,11 @@ int dccp_feat_change(struct dccp_minisoc
 	dccp_feat_debug(type, feature, *val);
 
 	if (!dccp_feat_is_valid_type(type)) {
-		pr_info("option type %d invalid in negotiation\n", type);
+		DCCP_WARN("option type %d invalid in negotiation\n", type);
 		return 1;
 	}
 	if (!dccp_feat_is_valid_length(type, feature, len)) {
-		pr_info("invalid length %d\n", len);
+		DCCP_WARN("invalid length %d\n", len);
 		return 1;
 	}
 	/* XXX add further sanity checks */
@@ -169,7 +169,8 @@ static int dccp_feat_reconcile(struct so
 			break;
 
 		default:
-			WARN_ON(1); /* XXX implement res */
+			DCCP_BUG("Fell through, feat=%d", opt->dccpop_feat);
+			/* XXX implement res */
 			return -EFAULT;
 		}
 
@@ -329,7 +330,7 @@ static void dccp_feat_empty_confirm(stru
 	switch (type) {
 	case DCCPO_CHANGE_L: opt->dccpop_type = DCCPO_CONFIRM_R; break;
 	case DCCPO_CHANGE_R: opt->dccpop_type = DCCPO_CONFIRM_L; break;
-	default: 	     pr_info("invalid type %d\n", type); return;
+	default: 	     DCCP_WARN("invalid type %d\n", type); return;
 
 	}
 	opt->dccpop_feat = feature;
@@ -427,7 +428,7 @@ int dccp_feat_confirm_recv(struct sock *
 	switch (type) {
 	case DCCPO_CONFIRM_L: t = DCCPO_CHANGE_R; break;
 	case DCCPO_CONFIRM_R: t = DCCPO_CHANGE_L; break;
-	default: 	      pr_info("invalid type %d\n", type);
+	default: 	      DCCP_WARN("invalid type %d\n", type);
 			      return 1;
 
 	}
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -128,21 +128,18 @@ static int dccp_check_seqno(struct sock 
 		     DCCP_PKT_WITHOUT_ACK_SEQ))
 			dp->dccps_gar = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	} else {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: Step 6 failed for %s packet, "
-					    "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
-					    "(P.ackno %s or LAWL(%llu) <= P.ackno(%llu) <= S.AWH(%llu), "
-					    "sending SYNC...\n",
-			       dccp_packet_name(dh->dccph_type),
-			       (unsigned long long) lswl,
-			       (unsigned long long)
-			       DCCP_SKB_CB(skb)->dccpd_seq,
-			       (unsigned long long) dp->dccps_swh,
-			       (DCCP_SKB_CB(skb)->dccpd_ack_seq =
+		DCCP_WARN("DCCP: Step 6 failed for %s packet, "
+			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
+			  "(P.ackno %s or LAWL(%llu) <= P.ackno(%llu) <= S.AWH(%llu), "
+			  "sending SYNC...\n",  dccp_packet_name(dh->dccph_type),
+			  (unsigned long long) lswl,
+			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_seq,
+			  (unsigned long long) dp->dccps_swh,
+			  (DCCP_SKB_CB(skb)->dccpd_ack_seq =
 			        DCCP_PKT_WITHOUT_ACK_SEQ) ? "doesn't exist" : "exists",
-			       (unsigned long long) lawl,
-			       (unsigned long long)
-			       DCCP_SKB_CB(skb)->dccpd_ack_seq,
-			       (unsigned long long) dp->dccps_awh);
+			  (unsigned long long) lawl,
+			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_ack_seq,
+			  (unsigned long long) dp->dccps_awh);
 		dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq, DCCP_PKT_SYNC);
 		return -1;
 	}
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -747,7 +747,7 @@ int dccp_invalid_packet(struct sk_buff *
 
 	/* If the packet is shorter than 12 bytes, drop packet and return */
 	if (!pskb_may_pull(skb, sizeof(struct dccp_hdr))) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: pskb_may_pull failed\n");
+		DCCP_WARN("pskb_may_pull failed\n");
 		return 1;
 	}
 
@@ -755,7 +755,7 @@ int dccp_invalid_packet(struct sk_buff *
 
 	/* If P.type is not understood, drop packet and return */
 	if (dh->dccph_type >= DCCP_PKT_INVALID) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: invalid packet type\n");
+		DCCP_WARN("invalid packet type\n");
 		return 1;
 	}
 
@@ -763,16 +763,14 @@ int dccp_invalid_packet(struct sk_buff *
 	 * If P.Data Offset is too small for packet type, drop packet and return
 	 */
 	if (dh->dccph_doff < dccp_hdr_len(skb) / sizeof(u32)) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.Data Offset(%u) "
-					    "too small\n", dh->dccph_doff);
+		DCCP_WARN("P.Data Offset(%u) too small\n", dh->dccph_doff);
 		return 1;
 	}
 	/*
 	 * If P.Data Offset is too too large for packet, drop packet and return
 	 */
 	if (!pskb_may_pull(skb, dh->dccph_doff * sizeof(u32))) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.Data Offset(%u) "
-					    "too large\n", dh->dccph_doff);
+		DCCP_WARN("P.Data Offset(%u) too large\n", dh->dccph_doff);
 		return 1;
 	}
 
@@ -782,9 +780,8 @@ int dccp_invalid_packet(struct sk_buff *
 	 */
 	if (dh->dccph_type >= DCCP_PKT_DATA    &&
 	    dh->dccph_type <= DCCP_PKT_DATAACK && dh->dccph_x = 0)  {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.type (%s) not Data||Ack||"
-					    "DataAck, while P.X = 0\n",
-			       dccp_packet_name(dh->dccph_type));
+		DCCP_WARN("P.type (%s) not Data || [Data]Ack, while P.X = 0\n",
+			  dccp_packet_name(dh->dccph_type));
 		return 1;
 	}
 
@@ -794,9 +791,8 @@ int dccp_invalid_packet(struct sk_buff *
 	 */
 	cscov = dccp_csum_coverage(skb);
 	if (cscov > skb->len) {
-		LIMIT_NETDEBUG(KERN_WARNING
-			       "DCCP: P.CsCov %u exceeds packet length %d\n",
-			       dh->dccph_cscov, skb->len);
+		DCCP_WARN("P.CsCov %u exceeds packet length %d\n",
+			  dh->dccph_cscov, skb->len);
 		return 1;
 	}
 
@@ -823,9 +819,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 
 	/* Step 1: If header checksum is incorrect, drop packet and return */
 	if (dccp_v4_csum_finish(skb, skb->nh.iph->saddr, skb->nh.iph->daddr)) {
-		LIMIT_NETDEBUG(KERN_WARNING
-			       "%s: dropped packet with invalid checksum\n",
-			       __FUNCTION__);
+		DCCP_WARN("dropped packet with invalid checksum\n");
 		goto discard_it;
 	}
 
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -828,9 +828,7 @@ static int dccp_v6_rcv(struct sk_buff **
 	/* Step 1: If header checksum is incorrect, drop packet and return. */
 	if (dccp_v6_csum_finish(skb, &skb->nh.ipv6h->saddr,
 				     &skb->nh.ipv6h->daddr)) {
-		LIMIT_NETDEBUG(KERN_WARNING
-			       "%s: dropped packet with invalid checksum\n",
-			       __FUNCTION__);
+		DCCP_WARN("dropped packet with invalid checksum\n");
 		goto discard_it;
 	}
 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -84,8 +84,7 @@ void dccp_time_wait(struct sock *sk, int
 		 * socket up.  We've got bigger problems than
 		 * non-graceful socket closings.
 		 */
-		LIMIT_NETDEBUG(KERN_INFO "DCCP: time wait bucket "
-					 "table overflow\n");
+		DCCP_WARN("time wait bucket table overflow\n");
 	}
 
 	dccp_done(sk);
@@ -289,9 +288,7 @@ EXPORT_SYMBOL_GPL(dccp_child_process);
 
 void dccp_reqsk_send_ack(struct sk_buff *skb, struct request_sock *rsk)
 {
-	pr_info(KERN_WARNING "DCCP: ACK packets are never sent in "
-			     "LISTEN/RESPOND state\n");
-	dump_stack();
+	DCCP_BUG("DCCP-ACK packets are never sent in LISTEN/RESPOND state");
 }
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_send_ack);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -239,9 +239,8 @@ int dccp_parse_options(struct sock *sk, 
 		}
 			break;
 		default:
-			pr_info("DCCP(%p): option %d(len=%d) not "
-				"implemented, ignoring\n",
-				sk, opt, len);
+			DCCP_CRIT("DCCP(%p): option %d(len=%d) not "
+				  "implemented, ignoring", sk, opt, len);
 			break;
 	        }
 
@@ -258,7 +257,7 @@ int dccp_parse_options(struct sock *sk, 
 out_invalid_option:
 	DCCP_INC_STATS_BH(DCCP_MIB_INVALIDOPT);
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_OPTION_ERROR;
-	pr_info("DCCP(%p): invalid option %d, len=%d\n", sk, opt, len);
+	DCCP_WARN("DCCP(%p): invalid option %d, len=%d", sk, opt, len);
 	return -1;
 }
 
@@ -448,8 +447,7 @@ static int dccp_insert_feat_opt(struct s
 	u8 *to;
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len + 3 > DCCP_MAX_OPT_LEN) {
-		LIMIT_NETDEBUG(KERN_INFO "DCCP: packet too small"
-			       " to insert feature %d option!\n", feat);
+		DCCP_WARN("packet too small for feature %d option!\n", feat);
 		return -1;
 	}
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -257,11 +257,8 @@ void dccp_write_xmit(struct sock *sk, in
 				err = dccp_wait_for_ccid(sk, skb, &timeo);
 				timeo = DCCP_XMIT_TIMEO;
 			}
-			if (err) {
-				printk(KERN_CRIT "%s:err at dccp_wait_for_ccid"
-						 " %d\n", __FUNCTION__, err);
-				dump_stack();
-			}
+			if (err)
+				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
 		}
 
 		skb_dequeue(&sk->sk_write_queue);
@@ -283,12 +280,9 @@ void dccp_write_xmit(struct sock *sk, in
 
 			err = dccp_transmit_skb(sk, skb);
 			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
-			if (err) {
-				printk(KERN_CRIT "%s:err from "
-					         "ccid_hc_tx_packet_sent %d\n",
-					         __FUNCTION__, err);
-				dump_stack();
-			}
+			if (err)
+				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
+					 err);
 		} else
 			kfree(skb);
 	}
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1033,8 +1033,7 @@ static int __init dccp_init(void)
 	} while (!dccp_hashinfo.ehash && --ehash_order > 0);
 
 	if (!dccp_hashinfo.ehash) {
-		printk(KERN_CRIT "Failed to allocate DCCP "
-				 "established hash table\n");
+		DCCP_CRIT("Failed to allocate DCCP established hash table");
 		goto out_free_bind_bucket_cachep;
 	}
 
@@ -1056,7 +1055,7 @@ static int __init dccp_init(void)
 	} while (!dccp_hashinfo.bhash && --bhash_order >= 0);
 
 	if (!dccp_hashinfo.bhash) {
-		printk(KERN_CRIT "Failed to allocate DCCP bind hash table\n");
+		DCCP_CRIT("Failed to allocate DCCP bind hash table");
 		goto out_free_dccp_ehash;
 	}
 
