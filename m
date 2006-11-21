From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Nov 2006 15:45:07 +0000
Subject: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <200611211545.07412@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Fix bug in calculation of first t_nom and first t_ipi

Problem:
--------
 Currently the inter-packet-interval for the first packet is set to 500msec instead
 of the 1 second specified in RFC 3448 (detailed derivation below).
 Furthermore, the code is complicated, since t_ipi is, in fact, added twice to t_0 = t_now.

Solution:
---------
 This patch
	* sets the initial value of t_ipi to 1 second, as per RFC 3448
	* simplifies the initial setting of t_ipi and t_delta through a case analysis


Detailed Derivation:
--------------------
 When the first CCID 3 packet is sent in ccid3_hc_tx_send_packet, t_ipi is set to 

		hctx->ccid3hctx_t_ipi = TFRC_INITIAL_IPI;

 which is USEC_PER_SEC / 4 = 250 msec. This is then added twice to t_0, due to:

	case TFRC_SSTATE_NO_SENT:
		// ...
		/* Set nominal send time for initial packet */
		hctx->ccid3hctx_t_nom = now;
		timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
		rc = 0;
		break;
	// ...		
	/* Can we send? if so add options and add to packet history */
	if (rc = 0) {
		// ...
		timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
	}

 As a result, t_1 = t_0 + t_ipi = t_now + t_ipi 
                  = t_0 + 500msec

 This contradicts RFC 3448, due to the following requirements:

  a) Section 4.2, "Sender Initialization"
     "the value of X[/s] is set to 1 packet/second [...] The
      initial values for R (RTT) and t_RTO are undefined"

  b) Section 4.5, "Preventing Oscillations
     R_sqmean is undefined since R is undefined
     Therefore, X_init = X

  c) Section 4.6, "Scheduling of Packet Transmissions"
     
     t_ipi = X_init / s = 1 second

 A further simplification is possible for the initial `delta' value, which is
 defined in [RFC 3448, section 4.6] as

 	t_delta = min(t_ipi/2, t_gran/2)

 t_gran/2 here is TFRC_OPSYS_HALF_TIME_GRAN = USEC_PER_SEC / (2 * HZ).
 Since Linux always schedules with a higher granularity than 1 second, 
 the initial value of t_delta is thus simply 
	
 	t_delta = min(USEC_PER_SEC / 2 , USEC_PER_SEC / (2 * HZ))
 	        =  USEC_PER_SEC / (2 * HZ)

 Lastly, TFRC_INITIAL_IPI is not referenced anywhere else and can thus be removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   10 +++++-----
 net/dccp/ccids/ccid3.h |    2 --
 2 files changed, 5 insertions(+), 7 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -298,13 +298,13 @@ static int ccid3_hc_tx_send_packet(struc
 		hctx->ccid3hctx_last_win_count	 = 0;
 		hctx->ccid3hctx_t_last_win_count = now;
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-		hctx->ccid3hctx_t_ipi = TFRC_INITIAL_IPI;
+		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
+		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
+		/* Initial delta: minimum of 0.5 sec and t_gran/2 */
+		hctx->ccid3hctx_delta = TFRC_OPSYS_HALF_TIME_GRAN;
 
-		/* Set nominal send time for initial packet */
+		/* Set t_0 for initial packet */
 		hctx->ccid3hctx_t_nom = now;
-		timeval_add_usecs(&hctx->ccid3hctx_t_nom,
-				  hctx->ccid3hctx_t_ipi);
-		ccid3_calc_new_delta(hctx);
 		rc = 0;
 		break;
 	case TFRC_SSTATE_NO_FBACK:
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -49,8 +49,6 @@
 /* Two seconds as per CCID3 spec */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
-#define TFRC_INITIAL_IPI	   (USEC_PER_SEC / 4)
-
 /* In usecs - half the scheduling granularity as per RFC3448 4.6 */
 #define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
 
