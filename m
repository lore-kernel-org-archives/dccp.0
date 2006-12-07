From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:13:00 +0000
Subject: [Patch 6/12]: Sanity-check RTT samples
Message-Id: <200612072113.00521@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3] Sanity-check RTT samples

CCID3 performance depends much on the accuracy of RTT samples.  If RTT
samples grow too large, performance can be catastrophically poor.

To limit the amount of possible damage in such cases, the patch
 * introduces an upper limit which identifies a maximum `sane' RTT value;
 * uses a macro to enforce this upper limit.

Using a macro was given preference, since it is necessary to identify the
calling function in the warning message. Since exceeding this threshold
identifies a critical condition, DCCP_CRIT is used and not DCCP_WARN.

Many thanks to Ian McDonald for collaboration on this issue.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    2 ++
 net/dccp/ccids/ccid3.h |   10 ++++++++++
 2 files changed, 12 insertions(+)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -456,6 +456,7 @@ static void ccid3_hc_tx_packet_recv(stru
 				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
+		CCID3_RTT_SANITY_CHECK(r_sample);
 
 		/* Update RTT estimate by 
 		 * If (No feedback recv)
@@ -1005,6 +1006,7 @@ static void ccid3_hc_rx_packet_recv(stru
 				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
+		CCID3_RTT_SANITY_CHECK(r_sample);
 
 		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
 			hcrx->ccid3hcrx_rtt = r_sample;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -51,6 +51,16 @@
 /* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
 #define TFRC_T_MBI		   64
 
+/* What we think is a reasonable upper limit on RTT values */
+#define CCID3_SANE_RTT_MAX	   (4 * USEC_PER_SEC)
+
+#define CCID3_RTT_SANITY_CHECK(rtt) 			do {		   \
+		if (rtt > CCID3_SANE_RTT_MAX) {				   \
+			DCCP_CRIT("RTT (%ld) too large, substituting %ld", \
+				  rtt, CCID3_SANE_RTT_MAX);		   \
+			rtt = CCID3_SANE_RTT_MAX;			   \
+		} 					} while (0)
+
 enum ccid3_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
