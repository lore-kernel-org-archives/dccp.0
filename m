From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:52:09 +0000
Subject: [PATCH 11/15] packet_history: Convert dccphtx_tstamp to ktime_t
Message-Id: <20070819235209.GO24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c              |    7 +++----
 net/dccp/ccids/lib/packet_history.h |    3 +--
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index b21d811..e75efe7 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -401,7 +401,7 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 	}
 	dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, packet);
 
-	packet->dccphtx_tstamp = ktime_to_timeval(ktime_get_real());
+	packet->dccphtx_tstamp = ktime_get_real();
 	packet->dccphtx_seqno  = dccp_sk(sk)->dccps_gss;
 	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
 	packet->dccphtx_sent   = 1;
@@ -412,7 +412,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
 	struct dccp_tx_hist_entry *packet;
-	ktime_t now, t_hist;
+	ktime_t now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
 
@@ -451,12 +451,11 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_p = 1000000 / pinv;
 
 		now = ktime_get_real();
-		t_hist = timeval_to_ktime(packet->dccphtx_tstamp);
 		/*
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
 		 *	R_sample  =  (now - t_recvdata) - t_elapsed
 		 */
-		r_sample = dccp_sample_rtt(sk, now, &t_hist);
+		r_sample = dccp_sample_rtt(sk, now, &packet->dccphtx_tstamp);
 
 		/*
 		 * Update RTT estimate by
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index d9d6896..032bb61 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -40,7 +40,6 @@
 #include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-#include <linux/time.h>
 
 #include "../../dccp.h"
 
@@ -58,7 +57,7 @@ struct dccp_tx_hist_entry {
 	u64		 dccphtx_seqno:48,
 			 dccphtx_sent:1;
 	u32		 dccphtx_rtt;
-	struct timeval	 dccphtx_tstamp;
+	ktime_t		 dccphtx_tstamp;
 };
 
 struct dccp_tx_hist {
-- 
1.5.2.2

