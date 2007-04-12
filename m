From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Apr 2007 13:10:39 +0000
Subject: [PATCHv2  2/25]: Avoid accumulation of large send credit
Message-Id: <200704121410.39114@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Patch with changed commit message as suggested by Eddie.
No change in code.

Uploaded as 5i_CCID3_No-Bursts-Due-To-Idle-Times.diff

--------------------------> Patch v2 <----------------------------------------------
[CCID 3]: Avoid accumulation of large send credit

Problem:
--------
 Large backlogs of packets will accumulate in the CCID3 TX module when
  (i)   the application idles and/or 
  (ii)  the application emits at a rate slower than the allowed rate X/s and/or 
  (iii) due to scheduling inaccuracy (resolution only up to HZ). 
	
 The consequence is that a huge burst of packets can be sent immediately, which
 violates the allowed sending rate and can (worst case) choke the network.
 Furthermore (iii) is especially likely when using high-speed (Gbit) links.

Fix:
----
 Avoid any backlog of sending time which is greater than one whole t_ipi. This
 is a conservative tight bound which will ensure safe operation with regard to
 the allowed fair-share rate in a wide range of possible hardware configurations.
 The value is derived below with a simple model, showing that this choice is safe
 from an operational point of view.


 D e t a i l e d    D e r i v a t i o n    [not commit message]
 --------------------------------------------------------------
 Let t_nom < t_now be such that t_now = t_nom + n * t_ipi + t_r, where
 n is a natural number and t_r < t_ipi. Then 
 
 	t_nom - t_now = - (n*t_ipi + t_r)
 
 First consider n=0: the current packet is sent immediately, and for
 the next one the send time is
 	
 	t_nom'  =  t_nom + t_ipi  =  t_now + (t_ipi - t_r)
 
 Thus the next packet is sent t_r time units earlier. The result is
 burstier traffic, as the inter-packet spacing is reduced; this 
 burstiness is mentioned by [RFC 3448, 4.6]. 
 
 Now consider n=1. This case is illustrated below
 
 	|<----- t_ipi -------->|<-- t_r -->|
 
 	|----------------------|-----------|
 	t_nom                              t_now
 
 Not only can the next packet be sent t_r time units earlier, a third
 packet can additionally be sent at the same time. 
 
 This case can be generalised in that the packet scheduling mechanism
 now acts as a Token Bucket Filter whose bucket size equals n: when
 n=0, a packet can only be sent when the next token arrives. When n > 0,
 a burst of n packets can be sent immediately in addition to the tokens
 which arrive with rate rho = 1/t_ipi.
 
 The aim of CCID 3 is an on average smooth traffic with allowed sending
 rate X. The following determines the required bucket size n for the 
 purpose of achieving, over the period of one RTT R, an average allowed
 sending rate X.
 The number of bytes sent during this period is X*R. Tokens arrive with
 rate rho at the bucket, whose size n shall be determined now. Over the
 period of R, the TBF allows s * (n + R * rho) bytes to be sent, since
 each token represents a packet of size s. Hence we have the equation
 
 		s * (n + R * rho) = X * R
 	<=>	n + R/t_ipi	  = X/s * R = R / t_ipi
 
 which shows that n must be 0. Hence we can not allow a `credit' of
 t_nom - t_now > t_ipi time units to accrue in the packet scheduling.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -362,7 +362,15 @@ static int ccid3_hc_tx_send_packet(struc
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
-		ccid3_pr_debug("delay=%ld\n", (long)delay);
+		/*
+		 * Lagging behind for more than a full t_ipi: when this occurs,
+		 * a send credit accrues which causes packet storms, violating
+		 * even the average allowed sending rate. This case happens if
+		 * the application idles for some time, or if it emits packets
+		 * at a rate smaller than X/s. Avoid such accumulation.
+		 */
+		if (delay + (suseconds_t)hctx->ccid3hctx_t_ipi  <  0)
+			hctx->ccid3hctx_t_nom = now;
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
@@ -371,7 +379,7 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
+		else if (delay - (suseconds_t)hctx->ccid3hctx_delta  >=  0)
 			return delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, &now);
