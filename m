From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 12 Sep 2009 17:47:01 +0000
Subject: net-next-2.6 [PATCH 1/1] dccp: ccids whitespace-cleanup /
Message-Id: <20090912174701.GA5611@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: ccid whitespace/CodingStyle cleanup

No code change, cosmetical changes only:

 * whitespace cleanup via scripts/cleanfile,
 * remove self-references to filename at top of files,
 * fix coding style (extraneous brackets),
 * fix documentation style (kernel-doc-nano-HOWTO).

Thanks are due to Ivo Augusto Calado who raised these issues by 
submitting good-quality patches.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig              |    6 ++--
 net/dccp/ccids/ccid2.c              |    2 -
 net/dccp/ccids/ccid2.h              |    8 ++---
 net/dccp/ccids/ccid3.c              |    5 +--
 net/dccp/ccids/ccid3.h              |   50 +++++++++++++++++-------------------
 net/dccp/ccids/lib/loss_interval.c  |    7 ++---
 net/dccp/ccids/lib/loss_interval.h  |    2 -
 net/dccp/ccids/lib/packet_history.c |    4 --
 net/dccp/ccids/lib/packet_history.h |    1 
 net/dccp/ccids/lib/tfrc.h           |    4 --
 net/dccp/ccids/lib/tfrc_equation.c  |   26 +++++++-----------
 11 files changed, 48 insertions(+), 67 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/packet_history.c
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
@@ -128,7 +126,7 @@ u32 tfrc_tx_hist_rtt(struct tfrc_tx_hist
 
 
 /*
- * 	Receiver History Routines
+ *	Receiver History Routines
  */
 static struct kmem_cache *tfrc_rx_hist_slab;
 
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/lib/tfrc_equation.c
- *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
@@ -79,10 +77,10 @@
     }
 
   With the given configuration, we have, with M = TFRC_CALC_X_ARRSIZE-1,
-    lookup[0][0]  =  g(1000000/(M+1)) 		 =  1000000 * f(0.2%)
-    lookup[M][0]  =  g(1000000)			 =  1000000 * f(100%)
-    lookup[0][1]  =  g(TFRC_SMALLEST_P)		  = 1000000 * f(0.01%)
-    lookup[M][1]  =  g(TFRC_CALC_X_SPLIT)	 =  1000000 * f(5%)
+    lookup[0][0]  =  g(1000000/(M+1))		= 1000000 * f(0.2%)
+    lookup[M][0]  =  g(1000000)			= 1000000 * f(100%)
+    lookup[0][1]  =  g(TFRC_SMALLEST_P)		= 1000000 * f(0.01%)
+    lookup[M][1]  =  g(TFRC_CALC_X_SPLIT)	= 1000000 * f(5%)
 
   In summary, the two columns represent f(p) for the following ranges:
     * The first column is for   0.002  <= p <= 1.0
@@ -610,11 +608,10 @@ static inline u32 tfrc_binsearch(u32 fva
 
 /**
  * tfrc_calc_x - Calculate the send rate as per section 3.1 of RFC3448
- *
- *  @s: packet size          in bytes
- *  @R: RTT                  scaled by 1000000   (i.e., microseconds)
- *  @p: loss ratio estimate  scaled by 1000000
- *  Returns X_calc           in bytes per second (not scaled).
+ * @s: packet size          in bytes
+ * @R: RTT                  scaled by 1000000   (i.e., microseconds)
+ * @p: loss ratio estimate  scaled by 1000000
+ * Returns X_calc           in bytes per second (not scaled).
  */
 u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 {
@@ -630,17 +627,17 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 		return ~0U;
 	}
 
-	if (p <= TFRC_CALC_X_SPLIT) 		{     /* 0.0000 < p <= 0.05   */
+	if (p <= TFRC_CALC_X_SPLIT)		{     /* 0.0000 < p <= 0.05   */
 		if (p < TFRC_SMALLEST_P) {	      /* 0.0000 < p <  0.0001 */
 			DCCP_WARN("Value of p (%d) below resolution. "
 				  "Substituting %d\n", p, TFRC_SMALLEST_P);
 			index = 0;
-		} else 				      /* 0.0001 <= p <= 0.05  */
+		} else				      /* 0.0001 <= p <= 0.05  */
 			index =  p/TFRC_SMALLEST_P - 1;
 
 		f = tfrc_calc_x_lookup[index][1];
 
-	} else {	 			      /* 0.05   <  p <= 1.00  */
+	} else {				      /* 0.05   <  p <= 1.00  */
 		index = p/(1000000/TFRC_CALC_X_ARRSIZE) - 1;
 
 		f = tfrc_calc_x_lookup[index][0];
@@ -661,7 +658,6 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 
 /**
  *  tfrc_calc_x_reverse_lookup  -  try to find p given f(p)
- *
  *  @fvalue: function value to match, scaled by 1000000
  *  Returns closest match for p, also scaled by 1000000
  */
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/lib/loss_interval.c
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
@@ -21,7 +19,7 @@ static const int tfrc_lh_weights[NINTERV
 /* implements LIFO semantics on the array */
 static inline u8 LIH_INDEX(const u8 ctr)
 {
-	return (LIH_SIZE - 1 - (ctr % LIH_SIZE));
+	return LIH_SIZE - 1 - (ctr % LIH_SIZE);
 }
 
 /* the `counter' index always points at the next entry to be populated */
@@ -129,7 +127,8 @@ static inline u8 tfrc_lh_is_new_loss(str
 		(cur->li_is_closed || SUB16(new_loss->tfrchrx_ccval, cur->li_ccval) > 4);
 }
 
-/** tfrc_lh_interval_add  -  Insert new record into the Loss Interval database
+/**
+ * tfrc_lh_interval_add  -  Insert new record into the Loss Interval database
  * @lh:		   Loss Interval database
  * @rh:		   Receive history containing a fresh loss event
  * @calc_first_li: Caller-dependent routine to compute length of first interval
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -1,8 +1,6 @@
 #ifndef _DCCP_LI_HIST_
 #define _DCCP_LI_HIST_
 /*
- *  net/dccp/ccids/lib/loss_interval.h
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -1,8 +1,6 @@
 #ifndef _TFRC_H_
 #define _TFRC_H_
 /*
- *  net/dccp/ccids/lib/tfrc.h
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
@@ -32,7 +30,7 @@ extern int tfrc_debug;
 /* integer-arithmetic divisions of type (a * 1000000)/b */
 static inline u64 scaled_div(u64 a, u64 b)
 {
-	BUG_ON(b=0);
+	BUG_ON(b = 0);
 	return div64_u64(a * 1000000, b);
 }
 
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -66,9 +66,9 @@ config IP_DCCP_CCID3_RTO
 	    A value of 0 disables this feature by enforcing the value specified
 	    in RFC 3448. The following values have been suggested as bounds for
 	    experimental use:
-	    	* 16-20ms to match the typical multimedia inter-frame interval
-	    	* 100ms as a reasonable compromise [default]
-	    	* 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
+		* 16-20ms to match the typical multimedia inter-frame interval
+		* 100ms as a reasonable compromise [default]
+		* 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
 
 	    The default of 100ms is a compromise between a large value for
 	    efficient DCCP implementations, and a small value to avoid disrupting
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/ccid2.c
- *
  *  Copyright (c) 2005, 2006 Andrea Bittau <a.bittau@cs.ucl.ac.uk>
  *
  *  Changes to meet Linux coding standards, and DCCP infrastructure fixes.
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/ccid2.h
- *
  *  Copyright (c) 2005 Andrea Bittau <a.bittau@cs.ucl.ac.uk>
  *
  *  This program is free software; you can redistribute it and/or modify
@@ -40,14 +38,14 @@ struct ccid2_seq {
 #define CCID2_SEQBUF_LEN 1024
 #define CCID2_SEQBUF_MAX 128
 
-/** struct ccid2_hc_tx_sock - CCID2 TX half connection
- *
+/**
+ * struct ccid2_hc_tx_sock - CCID2 TX half connection
  * @ccid2hctx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
  * @ccid2hctx_packets_acked - Ack counter for deriving cwnd growth (RFC 3465)
  * @ccid2hctx_lastrtt -time RTT was last measured
  * @ccid2hctx_rpseq - last consecutive seqno
  * @ccid2hctx_rpdupack - dupacks since rpseq
-*/
+ */
 struct ccid2_hc_tx_sock {
 	u32			ccid2hctx_cwnd;
 	u32			ccid2hctx_ssthresh;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/ccid3.c
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
@@ -750,7 +748,8 @@ static int ccid3_hc_rx_insert_options(st
 	return 0;
 }
 
-/** ccid3_first_li  -  Implements [RFC 3448, 6.3.1]
+/**
+ * ccid3_first_li  -  Implements [RFC 5348, 6.3.1]
  *
  * Determine the length of the first loss interval via inverse lookup.
  * Assume that X_recv can be computed by the throughput equation
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/ccid3.h
- *
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *
@@ -75,8 +73,8 @@ enum ccid3_hc_tx_states {
 	TFRC_SSTATE_TERM,
 };
 
-/** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
- *
+/**
+ * struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
  * @ccid3hctx_x - Current sending rate in 64 * bytes per second
  * @ccid3hctx_x_recv - Receive rate    in 64 * bytes per second
  * @ccid3hctx_x_calc - Calculated rate in bytes per second
@@ -119,9 +117,9 @@ struct ccid3_hc_tx_sock {
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
 {
-    struct ccid3_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
-    BUG_ON(hctx = NULL);
-    return hctx;
+	struct ccid3_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
+	BUG_ON(hctx = NULL);
+	return hctx;
 }
 
 /* TFRC receiver states */
@@ -131,22 +129,22 @@ enum ccid3_hc_rx_states {
 	TFRC_RSTATE_TERM    = 127,
 };
 
-/** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
- *
- *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
- *  @ccid3hcrx_p  -  Current loss event rate (RFC 3448 5.4)
- *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
- *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
- *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of RTT
- *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
- *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
- *  @ccid3hcrx_hist  -  Packet history (loss detection + RTT sampling)
- *  @ccid3hcrx_li_hist  -  Loss Interval database
- *  @ccid3hcrx_s  -  Received packet size in bytes
- *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
+/**
+ * struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
+ * @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
+ * @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
+ * @ccid3hcrx_p  -  Current loss event rate (RFC 3448 5.4)
+ * @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ * @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
+ * @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
+ * @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ * @ccid3hcrx_rtt  -  Receiver estimate of RTT
+ * @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
+ * @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
+ * @ccid3hcrx_hist  -  Packet history (loss detection + RTT sampling)
+ * @ccid3hcrx_li_hist  -  Loss Interval database
+ * @ccid3hcrx_s  -  Received packet size in bytes
+ * @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
 struct ccid3_hc_rx_sock {
 	u8				ccid3hcrx_last_counter:4;
@@ -163,9 +161,9 @@ struct ccid3_hc_rx_sock {
 
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
 {
-    struct ccid3_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
-    BUG_ON(hcrx = NULL);
-    return hcrx;
+	struct ccid3_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
+	BUG_ON(hcrx = NULL);
+	return hcrx;
 }
 
 #endif /* _DCCP_CCID3_H_ */
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -70,7 +70,6 @@ struct tfrc_rx_hist_entry {
 
 /**
  * tfrc_rx_hist  -  RX history structure for TFRC-based protocols
- *
  * @ring:		Packet history for RTT sampling and loss detection
  * @loss_count:		Number of entries in circular history
  * @loss_start:		Movable index (for loss detection)
-- 
