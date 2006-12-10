From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:02:57 +0000
Subject: [PATCH 15/22] [DCCP] ccid3: Sanity-check RTT samples
Message-Id: <20061210030256.GQ17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

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
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    4 +++-
 net/dccp/ccids/ccid3.h |   10 ++++++++++
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 7618d51..122a716 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -456,8 +456,9 @@ static void ccid3_hc_tx_packet_recv(stru
 				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
+		CCID3_RTT_SANITY_CHECK(r_sample);
 
-		/* Update RTT estimate by 
+		/* Update RTT estimate by
 		 * If (No feedback recv)
 		 *    R = R_sample;
 		 * Else
@@ -1000,6 +1001,7 @@ static void ccid3_hc_rx_packet_recv(stru
 				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
+		CCID3_RTT_SANITY_CHECK(r_sample);
 
 		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
 			hcrx->ccid3hcrx_rtt = r_sample;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index da0ca3c..3fa0f69 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -51,6 +51,16 @@ #define TFRC_OPSYS_HALF_TIME_GRAN  (USEC
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
-- 
1.4.2.1.g3d5c

