From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jul 2008 18:14:00 +0000
Subject: [PATCH 4/7] dccp tfrc: Receiver history initialisation routine
Message-Id: <1217268843-19667-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch
 1) separates history allocation and initialisation, to facilitate early
    loss detection (implemented by a subsequent patch);

 2) removes duplication by using the existing tfrc_rx_hist_purge() if the
    allocation fails. This is now possible, since the initialisation routine
 3) zeroes out the entire history before using it.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |    2 +-
 net/dccp/ccids/lib/packet_history.c |   52 ++++++++++++++++++++---------------
 net/dccp/ccids/lib/packet_history.h |    2 +-
 3 files changed, 32 insertions(+), 24 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -153,7 +153,7 @@ extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 				struct sock *sk);
 extern u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
 				   const struct sk_buff *skb);
-extern int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h);
+extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *h, struct sock *sk);
 extern void tfrc_rx_hist_purge(struct tfrc_rx_hist *h);
 
 #endif /* _DCCP_PKT_HIST_ */
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -352,28 +352,6 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_handle_loss);
 
-int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h)
-{
-	int i;
-
-	for (i = 0; i <= TFRC_NDUPACK; i++) {
-		h->ring[i] = kmem_cache_alloc(tfrc_rx_hist_slab, GFP_ATOMIC);
-		if (h->ring[i] = NULL)
-			goto out_free;
-	}
-
-	h->loss_count = h->loss_start = 0;
-	return 0;
-
-out_free:
-	while (i-- != 0) {
-		kmem_cache_free(tfrc_rx_hist_slab, h->ring[i]);
-		h->ring[i] = NULL;
-	}
-	return -ENOBUFS;
-}
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_alloc);
-
 void tfrc_rx_hist_purge(struct tfrc_rx_hist *h)
 {
 	int i;
@@ -386,6 +364,36 @@ void tfrc_rx_hist_purge(struct tfrc_rx_hist *h)
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_purge);
 
+static int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h)
+{
+	int i;
+
+	memset(h, 0, sizeof(*h));
+
+	for (i = 0; i <= TFRC_NDUPACK; i++) {
+		h->ring[i] = kmem_cache_alloc(tfrc_rx_hist_slab, GFP_ATOMIC);
+		if (h->ring[i] = NULL) {
+			tfrc_rx_hist_purge(h);
+			return -ENOBUFS;
+		}
+	}
+	return 0;
+}
+
+int tfrc_rx_hist_init(struct tfrc_rx_hist *h, struct sock *sk)
+{
+	if (tfrc_rx_hist_alloc(h))
+		return -ENOBUFS;
+	/*
+	 * Initialise first entry with GSR to start loss detection as early as
+	 * possible. Code using this must not use any other fields. The entry
+	 * will be overwritten once the CCID updates its received packets.
+	 */
+	tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno = dccp_sk(sk)->dccps_gsr;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_init);
+
 /**
  * tfrc_rx_hist_rtt_last_s - reference entry to compute RTT samples against
  */
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -766,7 +766,7 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 
 	hcrx->state = TFRC_RSTATE_NO_DATA;
 	tfrc_lh_init(&hcrx->li_hist);
-	return tfrc_rx_hist_alloc(&hcrx->hist);
+	return tfrc_rx_hist_init(&hcrx->hist, sk);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
