From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Feb 2006 22:09:02 +0000
Subject: [PATCH 2/4] [DCCP] ccid2: coding style cleanups
Message-Id: <11411645422940-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

No changes in the logic where made.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ccids/ccid2.c |   76 ++++++++++++++++--------------------------------
 1 files changed, 26 insertions(+), 50 deletions(-)

1c6ddda9288aba6a761b45357d119a47df165d4a
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 11c73ab..e00e225 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -37,10 +37,7 @@
 
 static int ccid2_debug;
 
-#if 0
-#define CCID2_DEBUG
-#endif
-
+#undef CCID2_DEBUG
 #ifdef CCID2_DEBUG
 #define ccid2_pr_debug(format, a...) \
         do { if (ccid2_debug) \
@@ -56,10 +53,8 @@ static const int ccid2_seq_len = 128;
 static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 {
 	int len = 0;
-	struct ccid2_seq *seqp;
 	int pipe = 0;
-
-	seqp = hctx->ccid2hctx_seqh;
+	struct ccid2_seq *seqp = hctx->ccid2hctx_seqh;
 
 	/* there is data in the chain */
 	if (seqp != hctx->ccid2hctx_seqt) {
@@ -69,9 +64,8 @@ static void ccid2_hc_tx_check_sanity(con
 			pipe++;
 	
 		while (seqp != hctx->ccid2hctx_seqt) {
-			struct ccid2_seq *prev;
+			struct ccid2_seq *prev = seqp->ccid2s_prev;
 
-			prev = seqp->ccid2s_prev;
 			len++;
 			if (!prev->ccid2s_acked)
 				pipe++;
@@ -92,7 +86,7 @@ static void ccid2_hc_tx_check_sanity(con
 		seqp = seqp->ccid2s_prev;
 		len++;
 		BUG_ON(len > ccid2_seq_len);
-	} while(seqp != hctx->ccid2hctx_seqh);
+	} while (seqp != hctx->ccid2hctx_seqh);
 
 	BUG_ON(len != ccid2_seq_len);
 	ccid2_pr_debug("total len=%d\n", len);
@@ -141,7 +135,7 @@ static void ccid2_change_l_ack_ratio(str
 	 * -sorbo.
 	 */
 	if (val != 2) {
-		struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+		const struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 		int max = hctx->ccid2hctx_cwnd / 2;
 
 		/* round up */
@@ -179,9 +173,6 @@ static void ccid2_hc_tx_rto_expire(unsig
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 	long s;
 
-	/* XXX I don't think i'm locking correctly
-	 * -sorbo.
-	 */
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
 		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
@@ -278,36 +269,33 @@ static void ccid2_hc_tx_packet_sent(stru
 	/* We had an ack loss in this window... */
 	if (hctx->ccid2hctx_ackloss) {
 		if (hctx->ccid2hctx_arsent >= hctx->ccid2hctx_cwnd) {
-			hctx->ccid2hctx_arsent = 0;
-			hctx->ccid2hctx_ackloss = 0;
+			hctx->ccid2hctx_arsent	= 0;
+			hctx->ccid2hctx_ackloss	= 0;
 		}
-	}
-	/* No acks lost up to now... */
-	else {
+	} else {
+		/* No acks lost up to now... */
 		/* decrease ack ratio if enough packets were sent */
 		if (dp->dccps_l_ack_ratio > 1) {
 			/* XXX don't calculate denominator each time */
-			int denom;
+			int denom = dp->dccps_l_ack_ratio * dp->dccps_l_ack_ratio - 
+				    dp->dccps_l_ack_ratio;
 
-			denom = dp->dccps_l_ack_ratio * dp->dccps_l_ack_ratio - 
-				dp->dccps_l_ack_ratio;
 			denom = hctx->ccid2hctx_cwnd * hctx->ccid2hctx_cwnd / denom;
 
 			if (hctx->ccid2hctx_arsent >= denom) {
 				ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio - 1);
 				hctx->ccid2hctx_arsent = 0;
 			}
-		}
-		/* we can't increase ack ratio further [1] */
-		else {
+		} else {
+			/* we can't increase ack ratio further [1] */
 			hctx->ccid2hctx_arsent = 0; /* or maybe set it to cwnd*/
 		}
 	}
 
 	/* setup RTO timer */
-	if (!timer_pending(&hctx->ccid2hctx_rtotimer)) {
+	if (!timer_pending(&hctx->ccid2hctx_rtotimer))
 		ccid2_start_rto_timer(sk);
-	}
+
 #ifdef CCID2_DEBUG
 	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
 	ccid2_pr_debug("Sent: seq=%llu\n", seq);
@@ -320,7 +308,7 @@ static void ccid2_hc_tx_packet_sent(stru
 				       seqp->ccid2s_sent);
 			seqp = seqp->ccid2s_next;
 		}
-	} while(0);
+	} while (0);
 	ccid2_pr_debug("=====\n");
 	ccid2_hc_tx_check_sanity(hctx);
 #endif
@@ -378,7 +366,6 @@ static int ccid2_ackvector(struct sock *
 			*vec	= value;
 			*veclen = len;
 			return offset + (opt_ptr - options);
-			break;
 		}
 	}
 
@@ -416,13 +403,11 @@ static inline void ccid2_new_ack(struct 
 				hctx->ccid2hctx_ssacks = 0;
 				*maxincr = *maxincr - 1;
 			}
-		}
-		/* increased cwnd enough for this single ack */
-		else {
+		} else {
+			/* increased cwnd enough for this single ack */
 			hctx->ccid2hctx_ssacks = 0;
 		}
-	}
-	else {
+	} else {
 		hctx->ccid2hctx_ssacks = 0;
 		hctx->ccid2hctx_acks++;
 
@@ -444,8 +429,7 @@ static inline void ccid2_new_ack(struct 
 			       	       r, jiffies, seqp->ccid2s_seq);
 			hctx->ccid2hctx_srtt = r;
 			hctx->ccid2hctx_rttvar = r >> 1;
-		}
-		else {
+		} else {
 			/* RTTVAR */
 			long tmp = hctx->ccid2hctx_srtt - r;
 			if (tmp < 0)
@@ -528,12 +512,10 @@ static void ccid2_hc_tx_packet_recv(stru
 	if (hctx->ccid2hctx_rpdupack = -1) {
 		hctx->ccid2hctx_rpdupack = 0;
 		hctx->ccid2hctx_rpseq = seqno;
-	}
-	else {
+	} else {
 		/* check if packet is consecutive */
-		if ((hctx->ccid2hctx_rpseq + 1) = seqno) {
+		if ((hctx->ccid2hctx_rpseq + 1) = seqno)
 			hctx->ccid2hctx_rpseq++;
-		}
 		/* it's a later packet */
 		else if (after48(seqno, hctx->ccid2hctx_rpseq)) {
 			hctx->ccid2hctx_rpdupack++;
@@ -541,7 +523,6 @@ static void ccid2_hc_tx_packet_recv(stru
 			/* check if we got enough dupacks */
 			if (hctx->ccid2hctx_rpdupack > 			    hctx->ccid2hctx_numdupack) {
-
 				hctx->ccid2hctx_rpdupack = -1; /* XXX lame */
 				hctx->ccid2hctx_rpseq = 0;
 
@@ -559,7 +540,6 @@ static void ccid2_hc_tx_packet_recv(stru
 	case DCCP_PKT_ACK:
 	case DCCP_PKT_DATAACK:
 		break;
-	
 	default:
 		return;
 	}
@@ -612,11 +592,9 @@ static void ccid2_hc_tx_packet_recv(stru
 				    	if (state = 
 					    DCCP_ACKVEC_STATE_ECN_MARKED) {
 						loss = 1;
-					}
-					else {
+					} else
 						ccid2_new_ack(sk, seqp,
 							      &maxincr);
-					}
 
 					seqp->ccid2s_acked = 1;
 					ccid2_pr_debug("Got ack for %llu\n",
@@ -648,13 +626,11 @@ static void ccid2_hc_tx_packet_recv(stru
 	while (1) {
 		if (seqp->ccid2s_acked) {
 			done++;
-			if (done = hctx->ccid2hctx_numdupack) {
+			if (done = hctx->ccid2hctx_numdupack)
 				break;
-			}	
 		}
-		if (seqp = hctx->ccid2hctx_seqt) {
+		if (seqp = hctx->ccid2hctx_seqt)
 			break;
-		}
 		seqp = seqp->ccid2s_prev;
 	}
 
@@ -798,6 +774,6 @@ static __exit void ccid2_module_exit(voi
 module_exit(ccid2_module_exit);
 
 MODULE_AUTHOR("Andrea Bittau <a.bittau@cs.ucl.ac.uk>");
-MODULE_DESCRIPTION("DCCP TCP CCID2 CCID");
+MODULE_DESCRIPTION("DCCP TCP-Like (CCID2) CCID");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("net-dccp-ccid-2");
-- 
1.2.2.gd27d


