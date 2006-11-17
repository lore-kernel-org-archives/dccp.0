From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 18:02:16 +0000
Subject: [PATCH 4/7]: Migration to DCCP_BUG(_ON)
Message-Id: <200611171802.16355@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Implement warning scheme for BUG(_ON)

This patch is trivial, it replaces
	* DCCP_BUG()    for BUG()
	* DCCP_BUG_ON() for BUG_ON()

The benefit is in (i) more verbose output (conditions are printed to syslog)
and (ii) easier and more consistent replacement later on. 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c                  |    6 +++---
 net/dccp/ccids/ccid2.c             |   26 +++++++++++++-------------
 net/dccp/ccids/ccid3.c             |   24 ++++++++++++------------
 net/dccp/ccids/lib/tfrc_equation.c |    5 ++---
 net/dccp/feat.c                    |   20 ++++++++++----------
 net/dccp/options.c                 |    2 +-
 6 files changed, 41 insertions(+), 42 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -57,7 +57,7 @@ static void dccp_ackvec_insert_avr(struc
 					list_entry(av->dccpav_records.next,
 						   struct dccp_ackvec_record,
 						   dccpavr_node);
-		BUG_ON(before48(avr->dccpavr_ack_seqno,
+		DCCP_BUG_ON(before48(avr->dccpavr_ack_seqno,
 				head->dccpavr_ack_seqno));
 	}
 
@@ -121,7 +121,7 @@ int dccp_insert_option_ackvec(struct soc
 			copylen	-= tailsize;
 			len     -= tailsize;
 
-			BUG_ON((from + copylen) >
+			DCCP_BUG_ON((from + copylen) >
 			       &av->dccpav_buf[DCCP_MAX_ACKVEC_LEN]);
 		}
 
@@ -131,7 +131,7 @@ int dccp_insert_option_ackvec(struct soc
 
 		len -= copylen;
 	}
-	BUG_ON(len != 0);
+	DCCP_BUG_ON(len != 0);
 
 	/*
 	 *	From RFC 4340, A.2:
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -59,15 +59,15 @@ static void ccid2_hc_tx_check_sanity(con
 				pipe++;
 
 			/* packets are sent sequentially */
-			BUG_ON(seqp->ccid2s_seq <= prev->ccid2s_seq);
-			BUG_ON(time_before(seqp->ccid2s_sent,
+			DCCP_BUG_ON(seqp->ccid2s_seq <= prev->ccid2s_seq);
+			DCCP_BUG_ON(time_before(seqp->ccid2s_sent,
 					   prev->ccid2s_sent));
 
 			seqp = prev;
 		}
 	}
 
-	BUG_ON(pipe != hctx->ccid2hctx_pipe);
+	DCCP_BUG_ON(pipe != hctx->ccid2hctx_pipe);
 	ccid2_pr_debug("len of chain=%d\n", len);
 
 	do {
@@ -76,7 +76,7 @@ static void ccid2_hc_tx_check_sanity(con
 	} while (seqp != hctx->ccid2hctx_seqh);
 
 	ccid2_pr_debug("total len=%d\n", len);
-	BUG_ON(len != hctx->ccid2hctx_seqbufc * CCID2_SEQBUF_LEN);
+	DCCP_BUG_ON(len != hctx->ccid2hctx_seqbufc * CCID2_SEQBUF_LEN);
 }
 #else
 #define ccid2_pr_debug(format, a...)
@@ -189,7 +189,7 @@ static void ccid2_change_cwnd(struct cci
 	/* XXX do we need to change ack ratio? */
 	ccid2_pr_debug("change cwnd to %d\n", val);
 
-	BUG_ON(val < 1);
+	DCCP_BUG_ON(val < 1);
 	hctx->ccid2hctx_cwnd = val;
 }
 
@@ -263,7 +263,7 @@ static void ccid2_start_rto_timer(struct
 
 	ccid2_pr_debug("setting RTO timeout=%ld\n", hctx->ccid2hctx_rto);
 
-	BUG_ON(timer_pending(&hctx->ccid2hctx_rtotimer));
+	DCCP_BUG_ON(timer_pending(&hctx->ccid2hctx_rtotimer));
 	sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
 		       jiffies + hctx->ccid2hctx_rto);
 }
@@ -277,10 +277,10 @@ static void ccid2_hc_tx_packet_sent(stru
 
 	ccid2_hc_tx_check_sanity(hctx);
 
-	BUG_ON(!hctx->ccid2hctx_sendwait);
+	DCCP_BUG_ON(!hctx->ccid2hctx_sendwait);
 	hctx->ccid2hctx_sendwait = 0;
 	ccid2_change_pipe(hctx, hctx->ccid2hctx_pipe + 1);
-	BUG_ON(hctx->ccid2hctx_pipe < 0);
+	DCCP_BUG_ON(hctx->ccid2hctx_pipe < 0);
 
 	/* There is an issue.  What if another packet is sent between
 	 * packet_send() and packet_sent().  Then the sequence number would be
@@ -300,10 +300,10 @@ static void ccid2_hc_tx_packet_sent(stru
 
 		ccid2_pr_debug("allocating more space in history\n");
 		rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, GFP_KERNEL);
-		BUG_ON(rc); /* XXX what do we do? */
+		DCCP_BUG_ON(rc); /* XXX what do we do? */
 
 		next = hctx->ccid2hctx_seqh->ccid2s_next;
-		BUG_ON(next = hctx->ccid2hctx_seqt);
+		DCCP_BUG_ON(next = hctx->ccid2hctx_seqt);
 	}
 	hctx->ccid2hctx_seqh = next;
 
@@ -377,7 +377,7 @@ static int ccid2_ackvector(struct sock *
         unsigned char opt, len;
         unsigned char *value;
 
-	BUG_ON(offset < 0);
+	DCCP_BUG_ON(offset < 0);
 	options += offset;
 	opt_ptr = options;
 	if (opt_ptr >= opt_end)
@@ -420,7 +420,7 @@ static int ccid2_ackvector(struct sock *
 	return -1;
 
 out_invalid_option:
-	BUG_ON(1); /* should never happen... options were previously parsed ! */
+	DCCP_BUG("Invalid option - this should not happen (previous parsing)!");
 	return -1;
 }
 
@@ -534,7 +534,7 @@ static void ccid2_hc_tx_dec_pipe(struct 
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
 	ccid2_change_pipe(hctx, hctx->ccid2hctx_pipe-1);
-	BUG_ON(hctx->ccid2hctx_pipe < 0);
+	DCCP_BUG_ON(hctx->ccid2hctx_pipe < 0);
 
 	if (hctx->ccid2hctx_pipe = 0)
 		ccid2_hc_tx_kill_rto_timer(sk);
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -216,7 +216,7 @@ static void ccid3_hc_tx_no_feedback_time
 			 *  Else
 			 *    X_recv = X_calc / 4;
 			 */
-			BUG_ON(hctx->ccid3hctx_p >= TFRC_SMALLEST_P &&
+			DCCP_BUG_ON(hctx->ccid3hctx_p >= TFRC_SMALLEST_P &&
 			       hctx->ccid3hctx_x_calc = 0);
 
 			/* check also if p is zero -> x_calc is infinity? */
@@ -263,7 +263,7 @@ static int ccid3_hc_tx_send_packet(struc
 	long delay;
 	int rc = -ENOTCONN;
 
-	BUG_ON(hctx = NULL);
+	DCCP_BUG_ON(hctx = NULL);
 
 	/* Check if pure ACK or Terminating*/
 	/*
@@ -341,7 +341,7 @@ static void ccid3_hc_tx_packet_sent(stru
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
 
-	BUG_ON(hctx = NULL);
+	DCCP_BUG_ON(hctx = NULL);
 
 	dccp_timestamp(sk, &now);
 
@@ -427,7 +427,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	u32 x_recv;
 	u32 r_sample;
 
-	BUG_ON(hctx = NULL);
+	DCCP_BUG_ON(hctx = NULL);
 
 	/* we are only interested in ACKs */
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
@@ -561,7 +561,7 @@ static int ccid3_hc_tx_insert_options(st
 {
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
-	BUG_ON(hctx = NULL);
+	DCCP_BUG_ON(hctx = NULL);
 
 	if (sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN)
 		DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
@@ -577,7 +577,7 @@ static int ccid3_hc_tx_parse_options(str
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
 
-	BUG_ON(hctx = NULL);
+	DCCP_BUG_ON(hctx = NULL);
 
 	opt_recv = &hctx->ccid3hctx_options_received;
 
@@ -657,7 +657,7 @@ static void ccid3_hc_tx_exit(struct sock
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
-	BUG_ON(hctx = NULL);
+	DCCP_BUG_ON(hctx = NULL);
 
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
@@ -751,7 +751,7 @@ static int ccid3_hc_rx_insert_options(st
 	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
-	BUG_ON(hcrx = NULL);
+	DCCP_BUG_ON(hcrx = NULL);
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
@@ -979,7 +979,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
 	int loss;
 
-	BUG_ON(hcrx = NULL);
+	DCCP_BUG_ON(hcrx = NULL);
 
 	opt_recv = &dccp_sk(sk)->dccps_options_received;
 
@@ -1113,7 +1113,7 @@ static void ccid3_hc_rx_exit(struct sock
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 
-	BUG_ON(hcrx = NULL);
+	DCCP_BUG_ON(hcrx = NULL);
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
@@ -1132,7 +1132,7 @@ static void ccid3_hc_rx_get_info(struct 
 	if (sk->sk_state = DCCP_LISTEN)
 		return;
 
-	BUG_ON(hcrx = NULL);
+	DCCP_BUG_ON(hcrx = NULL);
 
 	info->tcpi_ca_state	= hcrx->ccid3hcrx_state;
 	info->tcpi_options	|= TCPI_OPT_TIMESTAMPS;
@@ -1147,7 +1147,7 @@ static void ccid3_hc_tx_get_info(struct 
 	if (sk->sk_state = DCCP_LISTEN)
 		return;
 
-	BUG_ON(hctx = NULL);
+	DCCP_BUG_ON(hctx = NULL);
 
 	info->tcpi_rto = hctx->ccid3hctx_t_rto;
 	info->tcpi_rtt = hctx->ccid3hctx_rtt;
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
@@ -591,7 +590,7 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 	if (R = 0)
 		R = 1; /* RTT can't be zero or else divide by zero */
 
-	BUG_ON(index >= TFRC_CALC_X_ARRSIZE);
+	DCCP_BUG_ON(index >= TFRC_CALC_X_ARRSIZE);
 
 	if (p >= TFRC_CALC_X_SPLIT)
 		f = tfrc_calc_x_lookup[index][0];
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -40,7 +40,7 @@ int dccp_feat_change(struct dccp_minisoc
 		if (opt->dccpop_feat = feature && opt->dccpop_type = type) {
 			dccp_pr_debug("Replacing old\n");
 			/* replace */
-			BUG_ON(opt->dccpop_val = NULL);
+			DCCP_BUG_ON(opt->dccpop_val = NULL);
 			kfree(opt->dccpop_val);
 			opt->dccpop_val	 = val;
 			opt->dccpop_len	 = len;
@@ -61,7 +61,7 @@ int dccp_feat_change(struct dccp_minisoc
 	opt->dccpop_conf = 0;
 	opt->dccpop_sc	 = NULL;
 
-	BUG_ON(opt->dccpop_val = NULL);
+	DCCP_BUG_ON(opt->dccpop_val = NULL);
 
 	list_add_tail(&opt->dccpop_node, &dmsk->dccpms_pending);
 	return 0;
@@ -122,7 +122,7 @@ static int dccp_feat_reconcile(struct so
 	u8 *spref, slen, *res = NULL;
 	int i, j, rc, agree = 1;
 
-	BUG_ON(rpref = NULL);
+	DCCP_BUG_ON(rpref = NULL);
 
 	/* check if we are the black sheep */
 	if (dp->dccps_role = DCCP_ROLE_CLIENT) {
@@ -138,8 +138,8 @@ static int dccp_feat_reconcile(struct so
 	 * Now we have server preference list in spref and client preference in
 	 * rpref
 	 */
-	BUG_ON(spref = NULL);
-	BUG_ON(rpref = NULL);
+	DCCP_BUG_ON(spref = NULL);
+	DCCP_BUG_ON(rpref = NULL);
 
 	/* FIXME sanity check vals */
 
@@ -196,7 +196,7 @@ static int dccp_feat_reconcile(struct so
 		}
 	} else {
 		/* recycle the confirm slot */
-		BUG_ON(opt->dccpop_sc->dccpoc_val = NULL);
+		DCCP_BUG_ON(opt->dccpop_sc->dccpoc_val = NULL);
 		kfree(opt->dccpop_sc->dccpoc_val);
 		dccp_pr_debug("recycling confirm slot\n");
 	}
@@ -260,7 +260,7 @@ static int dccp_feat_sp(struct sock *sk,
 	 * happen---if we understand a feature, we should have a preference list
 	 * with at least the default value.
 	 */
-	BUG_ON(rc = 1);
+	DCCP_BUG_ON(rc = 1);
 
 	return rc;
 }
@@ -480,11 +480,11 @@ void dccp_feat_clean(struct dccp_minisoc
 
 	list_for_each_entry_safe(opt, next, &dmsk->dccpms_pending,
 				 dccpop_node) {
-                BUG_ON(opt->dccpop_val = NULL);
+                DCCP_BUG_ON(opt->dccpop_val = NULL);
                 kfree(opt->dccpop_val);
 
 		if (opt->dccpop_sc != NULL) {
-			BUG_ON(opt->dccpop_sc->dccpoc_val = NULL);
+			DCCP_BUG_ON(opt->dccpop_sc->dccpoc_val = NULL);
 			kfree(opt->dccpop_sc->dccpoc_val);
 			kfree(opt->dccpop_sc);
 		}
@@ -494,7 +494,7 @@ void dccp_feat_clean(struct dccp_minisoc
 	INIT_LIST_HEAD(&dmsk->dccpms_pending);
 
 	list_for_each_entry_safe(opt, next, &dmsk->dccpms_conf, dccpop_node) {
-		BUG_ON(opt = NULL);
+		DCCP_BUG_ON(opt = NULL);
 		if (opt->dccpop_val != NULL)
 			kfree(opt->dccpop_val);
 		kfree(opt);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -497,7 +497,7 @@ static int dccp_insert_options_feat(stru
 					     opt->dccpop_sc->dccpoc_val,
 					     opt->dccpop_sc->dccpoc_len);
 
-			BUG_ON(!opt->dccpop_sc->dccpoc_val);
+			DCCP_BUG_ON(!opt->dccpop_sc->dccpoc_val);
 			kfree(opt->dccpop_sc->dccpoc_val);
 			kfree(opt->dccpop_sc);
 			opt->dccpop_sc = NULL;
