From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 17:55:34 +0000
Subject: [PATCH 05/11] CCID2: Allocate seq records on demand
Message-Id: <20060622175534.GE4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Allocate more sequence state on demand.  Each time a packet is sent out by
CCID2, a record of it needs to be kept.  This list of records grows
proportionally to cwnd.  Previously, the length of this list was hardcored and
therefore the cwnd could only grow to this value (of 128).  Now, records are
allocated on demand as necessary---cwnd may grow as it wishes.  The exceptional
case of when memory is not available is not handled gracefully.  Perhaps, cwnd
should be capped at that point.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index f953016..72fdc26 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -46,8 +46,6 @@ #else
 #define ccid2_pr_debug(format, a...)
 #endif
 
-static const int ccid2_seq_len = 128;
-
 #ifdef CCID2_DEBUG
 static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 {
@@ -73,7 +71,6 @@ static void ccid2_hc_tx_check_sanity(con
 			BUG_ON(seqp->ccid2s_seq <= prev->ccid2s_seq);
 			BUG_ON(time_before(seqp->ccid2s_sent,
 					   prev->ccid2s_sent));
-			BUG_ON(len > ccid2_seq_len);
 
 			seqp = prev;
 		}
@@ -85,16 +82,56 @@ static void ccid2_hc_tx_check_sanity(con
 	do {
 		seqp = seqp->ccid2s_prev;
 		len++;
-		BUG_ON(len > ccid2_seq_len);
 	} while (seqp != hctx->ccid2hctx_seqh);
 
-	BUG_ON(len != ccid2_seq_len);
 	ccid2_pr_debug("total len=%d\n", len);
+	BUG_ON(len != hctx->ccid2hctx_seqbufc*CCID2_SEQBUF_LEN);
 }
 #else
 #define ccid2_hc_tx_check_sanity(hctx) do {} while (0)
 #endif
 
+static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx, int num)
+{
+	struct ccid2_seq *seqp;
+	int i;
+
+	/* check if we have space to preserve the pointer to the buffer */
+	if (hctx->ccid2hctx_seqbufc >= (sizeof(hctx->ccid2hctx_seqbuf) /
+					sizeof(struct ccid2_seq*)))
+		return -ENOMEM;
+
+	/* allocate buffer and initialize linked list */
+	seqp = kmalloc(sizeof(*seqp) * num, gfp_any());
+	if (seqp = NULL)
+		return -ENOMEM;
+
+	for (i = 0; i < (num - 1); i++) {
+		seqp[i].ccid2s_next = &seqp[i + 1];
+		seqp[i + 1].ccid2s_prev = &seqp[i];
+	}
+	seqp[num - 1].ccid2s_next = seqp;
+	seqp->ccid2s_prev = &seqp[num - 1];
+
+	/* This is the first allocation.  Initiate the head and tail.  */
+	if (hctx->ccid2hctx_seqbufc = 0)
+		hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt = seqp;
+	else {
+		/* link the existing list with the one we just created */
+		hctx->ccid2hctx_seqh->ccid2s_next = seqp;
+		seqp->ccid2s_prev = hctx->ccid2hctx_seqh;
+
+		hctx->ccid2hctx_seqt->ccid2s_prev = &seqp[num - 1];
+		seqp[num - 1].ccid2s_next = hctx->ccid2hctx_seqt;
+	}
+
+	/* store the original pointer to the buffer so we can free it */
+	hctx->ccid2hctx_seqbuf[hctx->ccid2hctx_seqbufc] = seqp;
+	hctx->ccid2hctx_seqbufc++;
+
+	return 0;
+}
+
 static int ccid2_hc_tx_send_packet(struct sock *sk,
 				   struct sk_buff *skb, int len)
 {
@@ -233,6 +270,7 @@ static void ccid2_hc_tx_packet_sent(stru
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_seq *next;
 	u64 seq;
 
 	ccid2_hc_tx_check_sanity(hctx);
@@ -252,16 +290,24 @@ static void ccid2_hc_tx_packet_sent(stru
 	hctx->ccid2hctx_seqh->ccid2s_seq   = seq;
 	hctx->ccid2hctx_seqh->ccid2s_acked = 0;
 	hctx->ccid2hctx_seqh->ccid2s_sent  = jiffies;
-	hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqh->ccid2s_next;
+
+	next = hctx->ccid2hctx_seqh->ccid2s_next;
+	/* check if we need to alloc more space */
+	if (next = hctx->ccid2hctx_seqt) {
+		int rc;
+		
+		ccid2_pr_debug("allocating more space in history\n");
+		rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN);
+		BUG_ON(rc); /* XXX what do we do? */
+		
+		next = hctx->ccid2hctx_seqh->ccid2s_next;
+		BUG_ON(next = hctx->ccid2hctx_seqt);
+	}
+	hctx->ccid2hctx_seqh = next;
 
 	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->ccid2hctx_cwnd,
 		       hctx->ccid2hctx_pipe);
 
-	if (hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt) {
-		/* XXX allocate more space */
-		WARN_ON(1);
-	}
-
 	hctx->ccid2hctx_sent++;
 
 	/* Ack Ratio.  Need to maintain a concept of how many windows we sent */
@@ -677,33 +723,17 @@ static void ccid2_hc_tx_packet_recv(stru
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
         struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
-	int seqcount = ccid2_seq_len;
-	int i;
 
 	/* XXX init variables with proper values */
 	hctx->ccid2hctx_cwnd	  = 1;
 	hctx->ccid2hctx_ssthresh  = 10;
 	hctx->ccid2hctx_numdupack = 3;
+	hctx->ccid2hctx_seqbufc   = 0;
 
 	/* XXX init ~ to window size... */
-	hctx->ccid2hctx_seqbuf = kmalloc(sizeof(*hctx->ccid2hctx_seqbuf) *
-					 seqcount, gfp_any());
-	if (hctx->ccid2hctx_seqbuf = NULL)
+	if (ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN))
 		return -ENOMEM;
 
-	for (i = 0; i < (seqcount - 1); i++) {
-		hctx->ccid2hctx_seqbuf[i].ccid2s_next -					&hctx->ccid2hctx_seqbuf[i + 1];
-		hctx->ccid2hctx_seqbuf[i + 1].ccid2s_prev -					&hctx->ccid2hctx_seqbuf[i];
-	}
-	hctx->ccid2hctx_seqbuf[seqcount - 1].ccid2s_next -					hctx->ccid2hctx_seqbuf;
-	hctx->ccid2hctx_seqbuf->ccid2s_prev -					&hctx->ccid2hctx_seqbuf[seqcount - 1];
-
-	hctx->ccid2hctx_seqh	 = hctx->ccid2hctx_seqbuf;
-	hctx->ccid2hctx_seqt	 = hctx->ccid2hctx_seqh;
 	hctx->ccid2hctx_sent	 = 0;
 	hctx->ccid2hctx_rto	 = 3 * HZ;
 	hctx->ccid2hctx_srtt	 = -1;
@@ -722,10 +752,13 @@ static int ccid2_hc_tx_init(struct ccid 
 static void ccid2_hc_tx_exit(struct sock *sk)
 {
         struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	int i;
 
 	ccid2_hc_tx_kill_rto_timer(sk);
-	kfree(hctx->ccid2hctx_seqbuf);
-	hctx->ccid2hctx_seqbuf = NULL;
+
+	for (i = 0; i < hctx->ccid2hctx_seqbufc; i++)
+		kfree(hctx->ccid2hctx_seqbuf[i]);
+	hctx->ccid2hctx_seqbufc = 0;
 }
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 451a874..1a7904e 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -35,6 +35,9 @@ struct ccid2_seq {
 	struct ccid2_seq	*ccid2s_next;
 };
 
+#define CCID2_SEQBUF_LEN 256
+#define CCID2_SEQBUF_MAX 128
+
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
  *
  * @ccid2hctx_ssacks - ACKs recv in slow start
@@ -53,7 +56,8 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_ssthresh;
 	int			ccid2hctx_pipe;
 	int			ccid2hctx_numdupack;
-	struct ccid2_seq	*ccid2hctx_seqbuf;
+	struct ccid2_seq	*ccid2hctx_seqbuf[CCID2_SEQBUF_MAX];
+	int			ccid2hctx_seqbufc;
 	struct ccid2_seq	*ccid2hctx_seqh;
 	struct ccid2_seq	*ccid2hctx_seqt;
 	long			ccid2hctx_rto;
