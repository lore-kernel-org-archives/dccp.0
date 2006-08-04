From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Fri, 04 Aug 2006 11:07:52 +0000
Subject: [PATCH 1/1] CCID2: Experimental support for tcp_congestion_ops
Message-Id: <20060804110752.GA4262@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an experimental patch to bridge CCID2 and existing tcp congestion contrl
algorithms.  Added support for "tcp_congestion_ops" in CCID2.  This allows for
CCID2 to use different variants of congestion control.  The default is the RFC
CCID2, named with much originality, "ccid2".

I added support for a "tcp adaptor" which allows existing tcp algorithms to be
used withing CCID2.  They may be selected by asking for "tcp_name", where name
is "reno", "vegas", etc.

The following TCP algorithms are believed to work [at least partially] with
appropriate byte counting turned off:
bic, compound, cubic, highspeed, htcp, reno, scalable, vegas, veno.
These don't seem to work properly [I haven't added full support yet]:
hybla, lp, westwood.

This patch is mainly an RFC.  If people seem to like the idea, I can work on
making the patch look good.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 676333b..efc3139 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -196,6 +196,7 @@ #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
+#define DCCP_SOCKOPT_CCID_TX_ALGO	193
 
 #define DCCP_SERVICE_LIST_MAX_LEN      32
 
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 6d3a57b..ea9c7d4 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -46,6 +46,289 @@ #else
 #define ccid2_pr_debug(format, a...)
 #endif
 
+static u32 ccid2ca_ssthresh(struct sock *sk)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
+	return max(2, hctx->ccid2hctx_cwnd >> 1);
+}
+
+inline static void* ccid2ca_priv(struct sock *sk)
+{
+	return ccid2_hc_tx_sk(sk)->ccid2hctx_ca_priv;
+}
+
+static void ccid2ca_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+			       u32 in_flight, int good_ack)
+{
+        struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv *cap = ccid2ca_priv(sk);
+
+	/* check if we are dealing with a new ack vector */
+	/* XXX this method is unreliable.  Can get two seperate ACKs with same
+	 * highest ackno. */
+	if (ack != cap->ccid2cap_last_ack) {
+		/* If in slow-start, cwnd can increase at most Ack Ratio / 2 packets for
+		 * this single ack.  I round up.
+		 * -sorbo.
+		 */
+		cap->ccid2cap_maxincr = dccp_sk(sk)->dccps_l_ack_ratio >> 1;
+		cap->ccid2cap_maxincr++;
+		
+		cap->ccid2cap_last_ack = ack;
+	}
+
+	/* slow start */
+	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh) {
+		cap->ccid2cap_acks = 0;
+
+		/* We can increase cwnd at most maxincr [ack_ratio/2] */
+		if (cap->ccid2cap_maxincr) {
+			/* increase every 2 acks */
+			cap->ccid2cap_ssacks++;
+			if (cap->ccid2cap_ssacks = 2) {
+				ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd+1);
+				cap->ccid2cap_ssacks = 0;
+				cap->ccid2cap_maxincr--;
+			}
+		} else {
+			/* increased cwnd enough for this single ack */
+			cap->ccid2cap_ssacks = 0;
+		}
+	} else { /* additive increase */
+		cap->ccid2cap_ssacks = 0;
+		cap->ccid2cap_acks++;
+
+		if (cap->ccid2cap_acks >= hctx->ccid2hctx_cwnd) {
+			ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd + 1);
+			cap->ccid2cap_acks = 0;
+		}
+	}
+}
+
+static void ccid2ca_init(struct sock *sk)
+{
+        struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv *cap;
+
+	hctx->ccid2hctx_ca_priv = kmalloc(sizeof(*cap), GFP_ATOMIC); /* XXX */
+	BUG_ON(!hctx->ccid2hctx_ca_priv); /* XXX */
+	
+	cap = ccid2ca_priv(sk);
+	memset(cap, 0, sizeof(*cap));
+	cap->ccid2cap_last_ack = -1;
+}
+
+static void ccid2ca_release(struct sock *sk)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
+	if (hctx->ccid2hctx_ca_priv) {
+		kfree(hctx->ccid2hctx_ca_priv);
+		hctx->ccid2hctx_ca_priv = NULL;
+	}
+}
+
+#define CCID2_CA_NAME "ccid2"
+struct tcp_congestion_ops ccid2_rfc = {
+	.name		= CCID2_CA_NAME,
+	.owner		= THIS_MODULE,
+	.ssthresh	= ccid2ca_ssthresh,
+	.cong_avoid	= ccid2ca_cong_avoid,
+	.init		= ccid2ca_init,
+	.release	= ccid2ca_release
+};
+
+static void ccid2ca_tcp_sync_d2t(struct dccp_sock *dp, struct tcp_sock *tp)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk((struct sock*)dp);
+	u64 seq;
+
+	tp->snd_cwnd		= hctx->ccid2hctx_cwnd;
+	tp->snd_ssthresh	= hctx->ccid2hctx_ssthresh;
+
+	/* hybla gets minimum rtt from init.  We put a "high" value here to
+	 * avoid it.
+	 */
+	tp->srtt		= hctx->ccid2hctx_srtt = -1 ? HZ*3 :
+				  hctx->ccid2hctx_srtt;
+	/* htcp code failes due to division by 0 [an assert would be nice
+	 * there].  But it might be that it's just lame to have an srtt of 0, so
+	 * it's my code's fault.  -sorbo.
+	 */
+	if (tp->srtt = 0)
+		tp->srtt++;
+	tp->srtt <<= 3;
+
+	seq = dp->dccps_gss;
+	dccp_inc_seqno(&seq);
+	tp->snd_nxt = seq;
+}
+
+static void ccid2ca_tcp_sync_t2d(struct ccid2_hc_tx_sock *hctx,
+					struct tcp_sock *tp)
+{
+	ccid2_change_cwnd(hctx, tp->snd_cwnd);
+	hctx->ccid2hctx_ssthresh = tp->snd_ssthresh;
+}
+
+static void ccid2ca_tcp_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+				   u32 in_flight, int good_ack)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv_tcp *cap = ccid2ca_priv(sk);
+	struct sock *ts = (struct sock*) &cap->ccid2capt_tp;
+	struct inet_connection_sock *icsk = inet_csk(ts);
+
+	ccid2ca_tcp_sync_d2t(dccp_sk(sk), &cap->ccid2capt_tp);
+	BUG_ON(!icsk->icsk_ca_ops->cong_avoid);
+	icsk->icsk_ca_ops->cong_avoid(ts, ack, rtt, in_flight, good_ack);
+	ccid2ca_tcp_sync_t2d(hctx, &cap->ccid2capt_tp);
+	
+	tcp_sk(ts)->rx_opt.saw_tstamp = 0;
+}
+
+static u32 ccid2ca_tcp_ssthresh(struct sock *sk)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv_tcp *cap = ccid2ca_priv(sk);
+	struct sock *ts = (struct sock*) &cap->ccid2capt_tp;
+	struct inet_connection_sock *icsk = inet_csk(ts);
+	u32 rc;
+
+	ccid2ca_tcp_sync_d2t(dccp_sk(sk), &cap->ccid2capt_tp);
+	BUG_ON(!icsk->icsk_ca_ops->ssthresh);
+	rc = icsk->icsk_ca_ops->ssthresh(ts);
+	ccid2ca_tcp_sync_t2d(hctx, &cap->ccid2capt_tp);
+
+	return rc;
+}
+
+static void ccid2ca_tcp_set_state(struct sock *sk, u8 new_state)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv_tcp *cap = ccid2ca_priv(sk);
+	struct sock *ts = (struct sock*) &cap->ccid2capt_tp;
+	struct inet_connection_sock *icsk = inet_csk(ts);
+
+	if (!icsk->icsk_ca_ops->set_state)
+		return;
+
+	ccid2ca_tcp_sync_d2t(dccp_sk(sk), &cap->ccid2capt_tp);
+	icsk->icsk_ca_ops->set_state(ts, new_state);
+	ccid2ca_tcp_sync_t2d(hctx, &cap->ccid2capt_tp);
+}
+
+static void ccid2ca_tcp_pkts_acked(struct sock *sk, u32 pkts_acked)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv_tcp *cap = ccid2ca_priv(sk);
+	struct sock *ts = (struct sock*) &cap->ccid2capt_tp;
+	struct inet_connection_sock *icsk = inet_csk(ts);
+
+	if (!icsk->icsk_ca_ops->pkts_acked)
+		return;
+
+	ccid2ca_tcp_sync_d2t(dccp_sk(sk), &cap->ccid2capt_tp);
+	icsk->icsk_ca_ops->pkts_acked(ts, pkts_acked);
+	ccid2ca_tcp_sync_t2d(hctx, &cap->ccid2capt_tp);
+}
+
+static void ccid2ca_tcp_rtt_sample(struct sock *sk, u32 usrtt)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv_tcp *cap = ccid2ca_priv(sk);
+	struct sock *ts = (struct sock*) &cap->ccid2capt_tp;
+	struct inet_connection_sock *icsk = inet_csk(ts);
+	u32 delay = usecs_to_jiffies(usrtt);
+
+	/* an approximation */
+	tcp_sk(ts)->rx_opt.saw_tstamp = 1;
+	tcp_sk(ts)->rx_opt.rcv_tsecr = jiffies - delay;
+	tcp_sk(ts)->rx_opt.rcv_tsval = jiffies - (delay>>1); /* XXX */
+
+	if (!icsk->icsk_ca_ops->rtt_sample)
+		return;
+
+	ccid2ca_tcp_sync_d2t(dccp_sk(sk), &cap->ccid2capt_tp);
+	icsk->icsk_ca_ops->rtt_sample(ts, usrtt);
+	ccid2ca_tcp_sync_t2d(hctx, &cap->ccid2capt_tp);
+}
+
+static void ccid2ca_tcp_cwnd_event(struct sock *sk, enum tcp_ca_event event)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv_tcp *cap = ccid2ca_priv(sk);
+	struct sock *ts = (struct sock*) &cap->ccid2capt_tp;
+	struct inet_connection_sock *icsk = inet_csk(ts);
+
+	if (!icsk->icsk_ca_ops->cwnd_event)
+		return;
+
+	ccid2ca_tcp_sync_d2t(dccp_sk(sk), &cap->ccid2capt_tp);
+	icsk->icsk_ca_ops->cwnd_event(ts, event);
+	ccid2ca_tcp_sync_t2d(hctx, &cap->ccid2capt_tp);
+}
+
+static void ccid2ca_tcp_init(struct sock *sk)
+{
+        struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv_tcp *cap;
+	int rc;
+	struct tcp_sock *tp;
+
+	hctx->ccid2hctx_ca_priv = kmalloc(sizeof(*cap), GFP_ATOMIC); /* XXX */
+	BUG_ON(!hctx->ccid2hctx_ca_priv); /* XXX */
+	
+	cap = ccid2ca_priv(sk);
+	memset(cap, 0, sizeof(*cap));
+	tp = &cap->ccid2capt_tp;
+
+	/* set some default TCP values */
+	tp->snd_cwnd_clamp = 10000; /* XXX */
+	inet_csk((struct sock*)tp)->icsk_ca_state = TCP_CA_Open;
+	tp->mss_cache = 1;
+	ccid2ca_tcp_sync_d2t(dccp_sk(sk), tp);
+
+	/* Initialize the TCP congestion control algorithm */
+	/* We do this to make sure that reference counts are correct */
+	inet_csk((struct sock*) tp)->icsk_ca_ops = &tcp_init_congestion_ops;
+	tcp_init_congestion_control((struct sock*) tp);
+
+	rc = tcp_set_congestion_control((struct sock*) tp,
+					hctx->ccid2hctx_tcp_name);
+	BUG_ON(rc);
+
+	ccid2ca_tcp_sync_t2d(hctx, tp);
+}
+
+static void ccid2ca_tcp_release(struct sock *sk)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2ca_priv_tcp *cap = ccid2ca_priv(sk);
+
+	if (hctx->ccid2hctx_ca_priv) {
+		tcp_cleanup_congestion_control((struct sock*)
+					       &cap->ccid2capt_tp);
+		kfree(hctx->ccid2hctx_ca_priv);
+		hctx->ccid2hctx_ca_priv = NULL;
+	}
+}
+
+#define CCID2_CA_TCP_NAME "tcp_"
+struct tcp_congestion_ops ccid2_tcp = {
+	.name		= CCID2_CA_NAME,
+	.owner		= THIS_MODULE,
+	.ssthresh	= ccid2ca_tcp_ssthresh,
+	.cong_avoid	= ccid2ca_tcp_cong_avoid,
+	.init		= ccid2ca_tcp_init,
+	.release	= ccid2ca_tcp_release,
+	.set_state	= ccid2ca_tcp_set_state,
+	.pkts_acked	= ccid2ca_tcp_pkts_acked,
+	.rtt_sample	= ccid2ca_tcp_rtt_sample,
+	.cwnd_event	= ccid2ca_tcp_cwnd_event
+};
+
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 {
@@ -322,6 +605,9 @@ static inline void ccid2_profile_var(str
 
 static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, int val)
 {
+	if (val = hctx->ccid2hctx_cwnd)
+		return;
+
 	if (val = 0)
 		val = 1;
 
@@ -373,6 +659,9 @@ static void ccid2_hc_tx_rto_expire(unsig
 	ccid2_pr_debug("RTO_EXPIRE\n");
 
 	ccid2_hc_tx_check_sanity(hctx);
+	
+	if (hctx->ccid2hctx_ca_ops->set_state)
+		hctx->ccid2hctx_ca_ops->set_state(sk, TCP_CA_Loss);
 
 	/* back-off timer */
 	hctx->ccid2hctx_rto <<= 1;
@@ -392,8 +681,6 @@ static void ccid2_hc_tx_rto_expire(unsig
 
 	/* clear state about stuff we sent */
 	hctx->ccid2hctx_seqt	= hctx->ccid2hctx_seqh;
-	hctx->ccid2hctx_ssacks	= 0;
-	hctx->ccid2hctx_acks	= 0;
 	hctx->ccid2hctx_sent	= 0;
 
 	/* clear ack ratio state. */
@@ -402,6 +689,10 @@ static void ccid2_hc_tx_rto_expire(unsig
 	hctx->ccid2hctx_rpseq	 = 0;
 	hctx->ccid2hctx_rpdupack = -1;
 	ccid2_change_l_ack_ratio(sk, 1);
+	
+	if (hctx->ccid2hctx_ca_ops->set_state)
+		hctx->ccid2hctx_ca_ops->set_state(sk, TCP_CA_Open);
+
 	ccid2_hc_tx_check_sanity(hctx);
 out:
 	bh_unlock_sock(sk);
@@ -446,6 +737,9 @@ static void ccid2_hc_tx_packet_sent(stru
 
 	BUG_ON(!hctx->ccid2hctx_sendwait);
 	hctx->ccid2hctx_sendwait = 0;
+	if (hctx->ccid2hctx_pipe = 0 &&
+	    hctx->ccid2hctx_ca_ops->cwnd_event)
+		hctx->ccid2hctx_ca_ops->cwnd_event(sk, CA_EVENT_TX_START);
 	ccid2_change_pipe(hctx, hctx->ccid2hctx_pipe+1);
 	BUG_ON(hctx->ccid2hctx_pipe < 0);
 
@@ -601,42 +895,18 @@ static void ccid2_hc_tx_kill_rto_timer(s
 
 static inline void ccid2_new_ack(struct sock *sk,
 			         struct ccid2_seq *seqp,
-				 unsigned int *maxincr)
+				 u64 ackno)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	unsigned long r = (long)jiffies - (long)seqp->ccid2s_sent;
 
-	/* slow start */
-	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh) {
-		hctx->ccid2hctx_acks = 0;
-
-		/* We can increase cwnd at most maxincr [ack_ratio/2] */
-		if (*maxincr) {
-			/* increase every 2 acks */
-			hctx->ccid2hctx_ssacks++;
-			if (hctx->ccid2hctx_ssacks = 2) {
-				ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd+1);
-				hctx->ccid2hctx_ssacks = 0;
-				*maxincr = *maxincr - 1;
-			}
-		} else {
-			/* increased cwnd enough for this single ack */
-			hctx->ccid2hctx_ssacks = 0;
-		}
-	} else {
-		hctx->ccid2hctx_ssacks = 0;
-		hctx->ccid2hctx_acks++;
-
-		if (hctx->ccid2hctx_acks >= hctx->ccid2hctx_cwnd) {
-			ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd + 1);
-			hctx->ccid2hctx_acks = 0;
-		}
-	}
+	if (hctx->ccid2hctx_ca_ops->rtt_sample)
+		hctx->ccid2hctx_ca_ops->rtt_sample(sk, jiffies_to_usecs(r));
 
 	/* update RTO */
 	if (hctx->ccid2hctx_srtt = -1 ||
 	    ((long)jiffies - (long)hctx->ccid2hctx_lastrtt) > 	     hctx->ccid2hctx_srtt) {
-		unsigned long r = (long)jiffies - (long)seqp->ccid2s_sent;
 		int s;
 
 		/* first measurement */
@@ -694,6 +964,15 @@ #endif
 	/* we got a new ack, so re-start RTO timer */
 	ccid2_hc_tx_kill_rto_timer(sk);
 	ccid2_start_rto_timer(sk);
+
+	/* congestion control */
+	BUG_ON(!hctx->ccid2hctx_ca_ops->cong_avoid);
+	/* XXX we pass bougus paramets.
+	 * 1) good
+	 * 2) "in_flight".  We pretend we are always cwnd limited.
+	 */
+	hctx->ccid2hctx_ca_ops->cong_avoid(sk, ackno, hctx->ccid2hctx_srtt,
+					   hctx->ccid2hctx_cwnd, 1);
 }
 
 static void ccid2_hc_tx_dec_pipe(struct sock *sk)
@@ -707,33 +986,33 @@ static void ccid2_hc_tx_dec_pipe(struct 
 		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
-static void ccid2_congestion_event(struct ccid2_hc_tx_sock *hctx,
-				   struct ccid2_seq *seqp)
+static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 {
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
 	if (time_before(seqp->ccid2s_sent, hctx->ccid2hctx_last_cong)) {
 		dccp_pr_debug("Multiple losses in one RTT---treating as one\n");
 		return;
 	}	
  
 	hctx->ccid2hctx_last_cong = jiffies;
-	
-	ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd >> 1);
-	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd;
-	if (hctx->ccid2hctx_ssthresh < 2)
-		hctx->ccid2hctx_ssthresh = 2;
+
+	BUG_ON(!hctx->ccid2hctx_ca_ops->ssthresh);
+	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_ca_ops->ssthresh(sk);
+	ccid2_change_cwnd(hctx, hctx->ccid2hctx_ssthresh);
 }
 
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
-	u64 ackno, seqno;
+	u64 ackno, seqno, vec_ackno;
 	struct ccid2_seq *seqp;
 	unsigned char *vector;
 	unsigned char veclen;
 	int offset = 0;
 	int done = 0;
-	unsigned int maxincr = 0;
+	int acked = 0;
 
 	ccid2_hc_tx_check_sanity(hctx);
 	/* check reverse path congestion */
@@ -779,7 +1058,7 @@ static void ccid2_hc_tx_packet_recv(stru
 		return;
 	}
 
-	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
+	vec_ackno = ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	if (ackno > hctx->ccid2hctx_high_ack)
 		hctx->ccid2hctx_high_ack = ackno;
 
@@ -792,13 +1071,6 @@ static void ccid2_hc_tx_packet_recv(stru
 		}
 	}
 	
-	/* If in slow-start, cwnd can increase at most Ack Ratio / 2 packets for
-	 * this single ack.  I round up.
-	 * -sorbo.
-	 */
-	maxincr = dp->dccps_l_ack_ratio >> 1;
-	maxincr++;
-
 	/* go through all ack vectors */
 	while ((offset = ccid2_ackvector(sk, skb, offset,
 					 &vector, &veclen)) != -1) {
@@ -836,11 +1108,13 @@ static void ccid2_hc_tx_packet_recv(stru
 				    !seqp->ccid2s_acked) {
 				    	if (state =
 					    DCCP_ACKVEC_STATE_ECN_MARKED) {
-					    	ccid2_congestion_event(hctx,
+					    	ccid2_congestion_event(sk,
 								       seqp);
-					} else
+					} else {
 						ccid2_new_ack(sk, seqp,
-							      &maxincr);
+							      vec_ackno);
+						acked++;
+					}
 
 					seqp->ccid2s_acked = 1;
 					ccid2_pr_debug("Got ack for %llu\n",
@@ -864,6 +1138,9 @@ static void ccid2_hc_tx_packet_recv(stru
 			break;
 	}
 
+	if (acked && hctx->ccid2hctx_ca_ops->pkts_acked)
+		hctx->ccid2hctx_ca_ops->pkts_acked(sk, acked);
+
 	/* The state about what is acked should be correct now
 	 * Check for NUMDUPACK
 	 */
@@ -902,7 +1179,7 @@ static void ccid2_hc_tx_packet_recv(stru
 				 * order to detect multiple congestion events in
 				 * one ack vector.
 				 */
-				ccid2_congestion_event(hctx, seqp);
+				ccid2_congestion_event(sk, seqp);
 				ccid2_hc_tx_dec_pipe(sk);
 			}
 			if (seqp = hctx->ccid2hctx_seqt)
@@ -924,12 +1201,46 @@ static void ccid2_hc_tx_packet_recv(stru
 	ccid2_hc_tx_check_sanity(hctx);
 }
 
+static int ccid2_hc_tx_ca(struct sock *sk, char *name)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct tcp_congestion_ops *ca = NULL;
+
+	/* XXX should be like TCP---a list of available CAs which can be
+	 * registered at runtime.  However, there needs to be support for "ccid
+	 * globals" which currently do not exist.  I can prolly have a static
+	 * global in this file though...
+	 */
+	if (strcmp(name, CCID2_CA_NAME) = 0)
+		ca = &ccid2_rfc;
+	else if (strncmp(name, CCID2_CA_TCP_NAME, strlen(CCID2_CA_TCP_NAME))
+		 = 0) {
+		ca = &ccid2_tcp;
+		strncpy(hctx->ccid2hctx_tcp_name,
+			name + strlen(CCID2_CA_TCP_NAME),
+			sizeof(hctx->ccid2hctx_tcp_name) - 1);
+		hctx->ccid2hctx_tcp_name[sizeof(hctx->ccid2hctx_tcp_name)-1]= 0;
+	}
+
+	if (!ca)
+		return -1;
+
+	if (hctx->ccid2hctx_ca_ops && hctx->ccid2hctx_ca_ops->release)
+		hctx->ccid2hctx_ca_ops->release(sk);
+	hctx->ccid2hctx_ca_ops = ca;
+	if (hctx->ccid2hctx_ca_ops->init)
+		hctx->ccid2hctx_ca_ops->init(sk);
+	return 0;
+}
+
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
         struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
+	int rc;
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct ccid *tmp;
 
 	if (ccid2_profile) {
-		int rc;
 		int i;
  
 		for (i = 0; i < CCID2_PROF_LAST; i++) {
@@ -965,11 +1276,21 @@ static int ccid2_hc_tx_init(struct ccid 
 	hctx->ccid2hctx_rpdupack = -1;
 	hctx->ccid2hctx_last_cong = jiffies;
 	hctx->ccid2hctx_high_ack = 0;
+	hctx->ccid2hctx_ca_ops = NULL;
 
 	hctx->ccid2hctx_rtotimer.function = &ccid2_hc_tx_rto_expire;
 	hctx->ccid2hctx_rtotimer.data	  = (unsigned long)sk;
 	init_timer(&hctx->ccid2hctx_rtotimer);
 
+	/* XXX hack: store ccid reference in sk because the ca init routine
+	 * needs it
+	 */
+	tmp = dp->dccps_hc_tx_ccid;
+	dp->dccps_hc_tx_ccid = ccid;
+	rc = ccid2_hc_tx_ca(sk, CCID2_CA_NAME);
+	BUG_ON(rc != 0);
+	dp->dccps_hc_tx_ccid = tmp;
+
 	ccid2_hc_tx_check_sanity(hctx);
 	return 0;
 }
@@ -991,6 +1312,11 @@ static void ccid2_hc_tx_exit(struct sock
 		for (i = 0; i < CCID2_PROF_LAST; i++)
 			ccid2_pv_del(&hctx->ccid2hctx_profile.ccid2txp_vars[i]);
 	}
+
+	BUG_ON(!hctx->ccid2hctx_ca_ops);
+	if (hctx->ccid2hctx_ca_ops->release)
+		hctx->ccid2hctx_ca_ops->release(sk);
+	hctx->ccid2hctx_ca_ops = NULL;
 }
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -1050,6 +1376,24 @@ static int ccid2_hc_tx_profile(struct so
 	return 0;
 }
 
+static int ccid2_hc_tx_algo(struct sock *sk, u32 __user *optval,
+			    int __user *optlen)
+{
+	char name[DCCP_CA_NAME_MAX];
+	int len;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+	if (len > (sizeof(name) - 1))
+		return -EINVAL;
+
+	if (copy_from_user(name, optval, len))
+		return -EFAULT;
+	name[len] = 0;
+
+	return ccid2_hc_tx_ca(sk, name);
+}
+
 static int ccid2_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
@@ -1057,6 +1401,10 @@ static int ccid2_hc_tx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_TX_INFO:
 		if (ccid2_profile)
 			return ccid2_hc_tx_profile(sk, optval, optlen);
+
+	/* XXX should be SETsockopt */
+	case DCCP_SOCKOPT_CCID_TX_ALGO:
+		return ccid2_hc_tx_algo(sk, optval, optlen);
 	}
 	
 	return -ENOPROTOOPT;
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 5f4720a..05da321 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -86,8 +86,6 @@ #define CCID2_SEQBUF_MAX 128
 */
 struct ccid2_hc_tx_sock {
 	int			ccid2hctx_cwnd;
-	int			ccid2hctx_ssacks;
-	int			ccid2hctx_acks;
 	int			ccid2hctx_ssthresh;
 	int			ccid2hctx_pipe;
 	int			ccid2hctx_numdupack;
@@ -109,6 +107,21 @@ struct ccid2_hc_tx_sock {
 	unsigned long		ccid2hctx_last_cong;
 	struct ccid2_txprofile	ccid2hctx_profile;
 	u64			ccid2hctx_high_ack;
+	struct tcp_congestion_ops	*ccid2hctx_ca_ops;
+	void			*ccid2hctx_ca_priv;
+	char			ccid2hctx_tcp_name[TCP_CA_NAME_MAX];
+};
+#define DCCP_CA_NAME_MAX (TCP_CA_NAME_MAX+4+1)
+
+struct ccid2ca_priv {
+	int	ccid2cap_maxincr;
+	int	ccid2cap_acks;
+	int	ccid2cap_ssacks;
+	u64	ccid2cap_last_ack;
+};
+
+struct ccid2ca_priv_tcp {
+	struct tcp_sock			ccid2capt_tp;
 };
 
 struct ccid2_hc_rx_sock {
@@ -124,4 +137,7 @@ static inline struct ccid2_hc_rx_sock *c
 {
 	return ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
 }
+
+static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, int val);
+
 #endif /* _DCCP_CCID2_H_ */
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 857eefc..efcccf0 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -94,6 +94,7 @@ void tcp_init_congestion_control(struct 
 	if (icsk->icsk_ca_ops->init)
 		icsk->icsk_ca_ops->init(sk);
 }
+EXPORT_SYMBOL_GPL(tcp_init_congestion_control);
 
 /* Manage refcounts on socket close. */
 void tcp_cleanup_congestion_control(struct sock *sk)
@@ -104,6 +105,7 @@ void tcp_cleanup_congestion_control(stru
 		icsk->icsk_ca_ops->release(sk);
 	module_put(icsk->icsk_ca_ops->owner);
 }
+EXPORT_SYMBOL_GPL(tcp_cleanup_congestion_control);
 
 /* Used by sysctl to change default congestion control */
 int tcp_set_default_congestion_control(const char *name)
@@ -173,7 +175,7 @@ int tcp_set_congestion_control(struct so
 	rcu_read_unlock();
 	return err;
 }
-
+EXPORT_SYMBOL_GPL(tcp_set_congestion_control);
 
 /*
  * Linear increase during slow start
