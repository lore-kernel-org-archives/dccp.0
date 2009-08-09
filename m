From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:44 +0000
Subject: dccp-test-tree [PATCH 7/10] Extend the packet-history code to support ECN-marked-CE events
Message-Id: <1249847327-6792-8-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This extends the main accounting routine, tfrc_rx_congestion_event, to
also consider ECN-marks.

Loss and ECN-marks are treated separately: when there is already a loss
event, it is not necessary to also check for ECN marks (there will be at
most one new congestion event anyway).

Conversely, if there is an ECN-event, tracking a pending loss is disabled.
This is due to the fact that considering every possible combination of
loss_count with/-out ECN-marks creates a lot of complexity which does not
seem warranted -- comments added to point this out.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -360,6 +360,27 @@ bool tfrc_rx_congestion_event(struct tfrc_rx_hist *h,
 		 */
 		new_event = tfrc_lh_interval_add(lh, h, first_li, sk);
 		__three_after_loss(h);
+
+	} else if (dccp_data_packet(skb) && dccp_skb_is_ecn_ce(skb)) {
+		/*
+		 * We only test for ECN marks on data packets. This is the way
+		 * the RFC considers ECN marks - a future implementation may
+		 * find it useful to also check ECN marks on non-data packets.
+		 */
+		new_event = tfrc_lh_interval_add(lh, h, first_li, sk);
+		/*
+		 * Also combinations of loss and ECN-marks (as per the warning)
+		 * are not supported. The permutations of loss combined with or
+		 * without ECN-marks create a lot of complexity, which does not
+		 * seem warranted: ECN-marked packets immediately trigger con-
+		 * gestion events.
+		 * Testing is needed to see whether ignoring the loss_count in
+		 * light of an ECN-marked-CE event really has any disadvantages.
+		 */
+		if (new_event && h->loss_count) {
+			DCCP_WARN("Ignoring loss count due to ECN\n");
+			tfrc_rx_hist_resume_rtt_sampling(h);
+		}
 	}
 
 	/*
-- 
1.6.0.rc2

