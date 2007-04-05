From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:34:29 +0000
Subject: [PATCH 14/43]: CCID3 Packet Reception Step 6b  -  Detection of burst-losses
Message-Id: <200704051634.30034@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: CCID3 Packet Reception Step 6b  -  Detection of burst-losses

This completes the loss detection algorithm by providing a cleanup function
which recycles the RX history entries for continued loss detection when 
required. This test is necessary since otherwise bursts of packet losses
will not be detected correctly.

This code has also been verified using a test module.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -471,9 +471,33 @@ static int __two_after_loss(struct tfrc_
 /* recycle RX history records to continue loss detection if necessary */
 static void __three_after_loss(struct tfrc_rx_hist *h)
 {
-	/* XXX do nothing for now, this is part of a subsequent patch */
-	h->loss_start = hist_index(h, 3);
-	h->loss_count = 0;
+	/*
+	 * The distance between S0 and S1 is always greater than 1 and the NDP
+	 * count of S1 is smaller than this distance. Otherwise there would
+	 * have been no loss. Hence it is only necessary to see whether there
+	 * are further missing data packets between S1/S2 and S2/S3.
+	 */
+	int d2 = tfrc_rx_hist_delta_seqno(h, 1, 2),
+	    d3 = tfrc_rx_hist_delta_seqno(h, 2, 3),
+	    n2 = hist_entry(h, 2)->dccphrx_ndp,
+	    n3 = hist_entry(h, 3)->dccphrx_ndp;
+
+	if (d2 = 1 || n2 >= d2) {	/* S2 is successor to S1 */
+
+		if (d3 = 1 || n3 >= d3) {
+			/* S3 is successor of S2: entire hole is filled */
+			h->loss_start = hist_index(h, 3);
+			h->loss_count = 0;
+		} else {
+			/* gap between S2 and S3 */
+			h->loss_start = hist_index(h, 2);
+			h->loss_count = 1;
+		}
+
+	} else {			/* gap between S1 and S2 */
+		h->loss_start = hist_index(h, 1);
+		h->loss_count = 2;
+	}
 }
 
 /**
