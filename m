From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:14:37 +0000
Subject: [PATCH 05/29] Cheaper & smaller timestamping
Message-Id: <20070412211437.GF21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Currently dccp_timestamp calculates timestamps relative to an offset computed
at initialisation time.  This patch reduces the cost of timestamping by removing
the offset computation. This affords the advantages that

 * there are now fewer instructions per single timestamp;
 * the size of the dccp_sock becomes smaller (minus @dccps_epoch).

(NB: Using a reference epoch is not strictly necessary, since all known timestamping
     operations in DCCP only need relative time differences, but not absolute time.
     I have tested this patch for a while on different platforms, found no problems.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 include/linux/dccp.h                |    1 -
 net/dccp/ackvec.c                   |    4 ++--
 net/dccp/ccids/ccid3.c              |   18 +++++++++---------
 net/dccp/ccids/lib/packet_history.h |    2 +-
 net/dccp/dccp.h                     |    2 --
 net/dccp/input.c                    |    2 +-
 net/dccp/minisocks.c                |    1 -
 net/dccp/options.c                  |   22 +++-------------------
 net/dccp/proto.c                    |    1 -
 9 files changed, 16 insertions(+), 37 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index fda2148..c297212 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -511,7 +511,6 @@ struct dccp_sock {
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
 	struct dccp_options_received	dccps_options_received;
-	struct timeval			dccps_epoch;
 	enum dccp_role			dccps_role:2;
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 01030f3..a2bf318 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -82,7 +82,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
 		return -1;
 
-	dccp_timestamp(sk, &now);
+	do_gettimeofday(&now);
 	elapsed_time = timeval_delta(&now, &av->dccpav_time) / 10;
 
 	if (elapsed_time != 0 &&
@@ -321,7 +321,7 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 	}
 
 	av->dccpav_buf_ackno = ackno;
-	dccp_timestamp(sk, &av->dccpav_time);
+	do_gettimeofday(&av->dccpav_time);
 out:
 	return 0;
 
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index c623761..b756e95 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -273,7 +273,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 							      (2 * TFRC_T_MBI));
 
 			if (hctx->ccid3hctx_p = 0)
-				dccp_timestamp(sk, &now);
+				do_gettimeofday(&now);
 		} else {
 			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
 			hctx->ccid3hctx_x_recv <<= 4;
@@ -325,7 +325,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	dccp_timestamp(sk, &now);
+	do_gettimeofday(&now);
 
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_SENT:
@@ -418,7 +418,7 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 	}
 	dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, packet);
 
-	dccp_timestamp(sk, &now);
+	do_gettimeofday(&now);
 	packet->dccphtx_tstamp = now;
 	packet->dccphtx_seqno  = dccp_sk(sk)->dccps_gss;
 	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
@@ -469,7 +469,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		else				       /* can not exceed 100% */
 			hctx->ccid3hctx_p = 1000000 / pinv;
 
-		dccp_timestamp(sk, &now);
+		do_gettimeofday(&now);
 
 		/*
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
@@ -751,7 +751,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 
 	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
 
-	dccp_timestamp(sk, &now);
+	do_gettimeofday(&now);
 
 	switch (hcrx->ccid3hcrx_state) {
 	case TFRC_RSTATE_NO_DATA:
@@ -903,7 +903,7 @@ found:
 		return ~0;
 	}
 
-	dccp_timestamp(sk, &tstamp);
+	do_gettimeofday(&tstamp);
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
 	DCCP_BUG_ON(delta <= 0);
 
@@ -1050,7 +1050,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		if (opt_recv->dccpor_timestamp_echo = 0)
 			break;
 		rtt_prev = hcrx->ccid3hcrx_rtt;
-		dccp_timestamp(sk, &now);
+		do_gettimeofday(&now);
 		r_sample = dccp_sample_rtt(sk, &now, NULL);
 
 		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
@@ -1099,7 +1099,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		if (loss)
 			break;
 
-		dccp_timestamp(sk, &now);
+		do_gettimeofday(&now);
 		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
 		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
 			hcrx->ccid3hcrx_tstamp_last_ack = now;
@@ -1142,7 +1142,7 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	dccp_timestamp(sk, &hcrx->ccid3hcrx_tstamp_last_ack);
+	do_gettimeofday(&hcrx->ccid3hcrx_tstamp_last_ack);
 	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
 	hcrx->ccid3hcrx_s   = 0;
 	hcrx->ccid3hcrx_rtt = 0;
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 60d00f0..b40b9f9 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -151,7 +151,7 @@ static inline struct dccp_rx_hist_entry *
 		entry->dccphrx_ccval = dh->dccph_ccval;
 		entry->dccphrx_type  = dh->dccph_type;
 		entry->dccphrx_ndp   = ndp;
-		dccp_timestamp(sk, &entry->dccphrx_tstamp);
+		do_gettimeofday(&entry->dccphrx_tstamp);
 	}
 
 	return entry;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index d8ad27b..b00fc7a 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -401,8 +401,6 @@ extern int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
 			       unsigned char option,
 			       const void *value, unsigned char len);
 
-extern void dccp_timestamp(const struct sock *sk, struct timeval *tv);
-
 static inline suseconds_t timeval_usecs(const struct timeval *tv)
 {
 	return tv->tv_sec * USEC_PER_SEC + tv->tv_usec;
diff --git a/net/dccp/input.c b/net/dccp/input.c
index da6ec18..fc087fc 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -304,7 +304,7 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		if (dp->dccps_options_received.dccpor_timestamp_echo) {
 			struct timeval now;
 
-			dccp_timestamp(sk, &now);
+			do_gettimeofday(&now);
 			dp->dccps_syn_rtt = dccp_sample_rtt(sk, &now, NULL);
 		}
 
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 6d235b3..0596099 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -112,7 +112,6 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		newdp->dccps_service_list  = NULL;
 		newdp->dccps_service	   = dreq->dreq_service;
 		newicsk->icsk_rto	   = DCCP_TIMEOUT_INIT;
-		do_gettimeofday(&newdp->dccps_epoch);
 
 		if (dccp_feat_clone(sk, newsk))
 			goto out_free;
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 34d536d..72c11ef 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -158,7 +158,7 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 			opt_recv->dccpor_timestamp = ntohl(*(__be32 *)value);
 
 			dp->dccps_timestamp_echo = opt_recv->dccpor_timestamp;
-			dccp_timestamp(sk, &dp->dccps_timestamp_time);
+			do_gettimeofday(&dp->dccps_timestamp_time);
 
 			dccp_pr_debug("%s rx opt: TIMESTAMP=%u, ackno=%llu\n",
 				      dccp_role(sk), opt_recv->dccpor_timestamp,
@@ -370,28 +370,12 @@ int dccp_insert_option_elapsed_time(struct sock *sk, struct sk_buff *skb,
 
 EXPORT_SYMBOL_GPL(dccp_insert_option_elapsed_time);
 
-void dccp_timestamp(const struct sock *sk, struct timeval *tv)
-{
-	const struct dccp_sock *dp = dccp_sk(sk);
-
-	do_gettimeofday(tv);
-	tv->tv_sec  -= dp->dccps_epoch.tv_sec;
-	tv->tv_usec -= dp->dccps_epoch.tv_usec;
-
-	while (tv->tv_usec < 0) {
-		tv->tv_sec--;
-		tv->tv_usec += USEC_PER_SEC;
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_timestamp);
-
 int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
 {
 	struct timeval tv;
 	__be32 now;
 
-	dccp_timestamp(sk, &tv);
+	do_gettimeofday(&tv);
 	now = htonl(timeval_usecs(&tv) / 10);
 	/* yes this will overflow but that is the point as we want a
 	 * 10 usec 32 bit timer which mean it wraps every 11.9 hours */
@@ -411,7 +395,7 @@ static int dccp_insert_option_timestamp_echo(struct sock *sk,
 	int len, elapsed_time_len;
 	unsigned char *to;
 
-	dccp_timestamp(sk, &now);
+	do_gettimeofday(&now);
 	elapsed_time = timeval_delta(&now, &dp->dccps_timestamp_time) / 10;
 	elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
 	len = 6 + elapsed_time_len;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 6607b7b..7337e39 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -172,7 +172,6 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	dccp_minisock_init(&dp->dccps_minisock);
-	do_gettimeofday(&dp->dccps_epoch);
 
 	/*
 	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
-- 
1.5.0.6

