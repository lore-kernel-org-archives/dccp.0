From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Mon, 22 Jan 2007 04:11:23 +0000
Subject: [PATCH 2/3] DCCP: Calculate RTT earlier
Message-Id: <200701221711.24586.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

To make life easier we get the initial rtt from the difference between the
request and response packets. This is proposed as an erratum to RFC4342.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/input.c b/net/dccp/input.c
index b06389c..a0e2faa 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -18,6 +18,7 @@
 #include "ackvec.h"
 #include "ccid.h"
 #include "dccp.h"
+#include "ccids/ccid3.h"
 
 static void dccp_fin(struct sock *sk, struct sk_buff *skb)
 {
@@ -290,6 +291,19 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 	if (dh->dccph_type = DCCP_PKT_RESPONSE) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 		struct dccp_sock *dp = dccp_sk(sk);
+		const struct dccp_minisock *dmsk = dccp_msk(sk);
+
+		if (dmsk->dccpms_tx_ccid = DCCPC_CCID3) {
+			struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+			struct timeval now;
+
+			do_gettimeofday(&now);
+			hctx->ccid3hctx_rtt = timeval_delta(&now,
+			  &dp->dccps_epoch);
+
+			dccp_pr_debug("Received DCCP_PKT_RESPONSE, rtt =%u\n",
+			  hctx->ccid3hctx_rtt);
+		}
 
 		/* Stop the REQUEST timer */
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
