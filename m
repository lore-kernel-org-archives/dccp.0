From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Jan 2008 16:47:58 +0000
Subject: [DCCP] [Announce]: Test tree updates
Message-Id: <20080107164758.GA19512@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an edited list of recent changes in the test tree

	git://eden-feed.erg.abdn.ac.uk/dccp_exp

At the top of each block is the name of the patch, followed by a short 
description of the change, and the actual (or abridged if obvious) inter-diff.

Some of these changes refer to improved patches/bug-fixes, which are to be
submitted soon.

Gerrit

========================================
[DCCP]: Registration routines for changing feature values


=> Added symbolic constants for the Sequence Window / Ack Ratio limits
=> Added these constants to feat.c / ccid2.c (not shown)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -14,6 +14,15 @@
 #include <linux/types.h>
 #include "dccp.h"
 
+/*
+ * Known limits of feature values.
+ */
+/* Ack Ratio takes 2-byte integer values (11.3) */
+#define DCCPF_ACK_RATIO_MAX	0xFFFF
+/* Wmin2 and Wmax=2^46-1 from 7.5.2 */
+#define DCCPF_SEQ_WMIN		32
+#define DCCPF_SEQ_WMAX		0x3FFFFFFFFFFFull
+
 enum dccp_feat_type {
 	FEAT_AT_RX   = 1,	/* located at RX side of half-connection  */
 	FEAT_AT_TX   = 2,	/* located at TX side of half-connection  */

========================================
[DCCP]: Implement both feature-local and feature-remote Sequence Window feature

=> Removed the default initialisation of the Sequence Window feature value.
    This is redundant, a better solution is implemented in subsequent patch set.
=> Also calls the Sequence Window handlers immediately, so that the sequence
    and acknowledgment validity windows are updated.

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1086,19 +1086,6 @@ int dccp_feat_init(struct sock *sk)
 		rc = dccp_feat_register_sp(fn, sp[i].feat_num, sp[i].is_local,
 					sp[i].mandatory, sp[i].val, sp[i].len);
 
-	/*
-	 * Initial values for the remote and local Sequence Window feature. This
-	 * is only for the client startup phase, to seed AWL/SWL. Until then,
-	 *  - the default of 100 is enough for 75 Request-retransmissions,
-	 *  - sequence window checks are not performed in state LISTEN/REQUEST,
-	 *  - the only Ack window check is for the Ack completing the handshake.
-	 * After the handshake, local/remote Sequence Window will be updated
-	 * with the negotiated values (or the defaults again if not different).
-	 * The server's AWL/SWL derive directly from the negotiated values.
-	 */
-	for (i = 0; rc = 0 && i <= 1; i++)
-		rc = dccp_feat_activate(sk, DCCPF_SEQUENCE_WINDOW, i, NULL);
-
 	kfree(sp[0].val);
 	kfree(sp[1].val);
 	return rc;
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -319,10 +319,17 @@ int dccp_hdlr_ccid(struct sock *sk, u64 
 
 int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx)
 {
-	if (rx)
-		dccp_sk(sk)->dccps_r_seq_win = seq_win;
-	else
-		dccp_sk(sk)->dccps_l_seq_win = seq_win;
+	struct dccp_sock *dp = dccp_sk(sk);
+	
+	if (rx) {
+		dp->dccps_r_seq_win = seq_win;
+		/* propagate changes to update SWL/SWH */
+		dccp_update_gsr(sk, dp->dccps_gsr);
+	} else {
+		dp->dccps_l_seq_win = seq_win;
+		/* propagate changes to update AWL */
+		dccp_update_gss(sk, dp->dccps_gss);
+	}
 	return 0;
 }
 
========================================
[DCCP]: Support exchange of NN options in (PART)OPEN state

=> Lifted the restriction to exchanging only Ack Ratio options, since Sequence
    Window values also need to be updated in established state.
    Patches to actually do this for CCID2 are work in progress.

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1176,12 +1177,7 @@ static u8 dccp_feat_handle_nn_establishe
 	} else if (type != FEAT_NN) {
 		return 0;
 	}
-	/*
-	 * The restriction to Ack Ratio is here for safety: it may be possible
-	 * to lift this and also update Sequence Window dynamically.
-	 */
-	 if (feat != DCCPF_ACK_RATIO)
-		return 0;
+
 	/*
 	 * We don't accept empty Confirms, since in fast-path feature
 	 * negotiation the values are enabled immediately after sending
========================================
[ACKVEC]: Update Ack Vector input routine

=> Added a "cope with large bursts" recovery hook as follows:

  When a packet is missing, the Ack Vector code normally reserves one entry. This
  causes problems with larger losses, since the space requirements are O(burst_length).
  
  This patch defines a threshold for bursty loss, when exceeding this threshold,
  Ack Vector cells are populated up to their limit, without the expensive space
  reservation. 
  
  The advantage of this strategy is to reduce Ack Vector length under heavier loss
  conditions.

--- b/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -27,6 +27,9 @@
 #define DCCPAV_NUM_ACKVECS	2
 #define DCCPAV_MAX_ACKVEC_LEN	(DCCP_SINGLE_OPT_MAXLEN * DCCPAV_NUM_ACKVECS)
 
+/* Threshold for coping with large bursts of losses */
+#define DCCPAV_BURST_THRESH	(DCCPAV_MAX_ACKVEC_LEN / 8)
+
 enum dccp_ackvec_states {
 	DCCPAV_RECEIVED =	0x00,
 	DCCPAV_ECN_MARKED =	0x40,
--- b/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -206,10 +206,38 @@
  * @seqno:	 sequence number of the first packet in @num_packets
  * @state:	 state in which packet carrying @seqno was received
  */
-static void dccp_ackvec_add_new(struct dccp_ackvec *av, u16 num_packets,
+static void dccp_ackvec_add_new(struct dccp_ackvec *av, u32 num_packets,
 				u64 seqno, enum dccp_ackvec_states state)
 {
-	if ((num_packets + dccp_ackvec_buflen(av)) >= DCCPAV_MAX_ACKVEC_LEN) {
+	u32 num_cells = num_packets;
+
+	if (num_packets > DCCPAV_BURST_THRESH) {
+		u32 lost_packets = num_packets - 1;
+
+		DCCP_WARN("Warning: large burst loss (%u)\n", lost_packets);
+		/*
+		 * We received 1 packet and have a loss of size "num_packets-1"
+		 * which we squeeze into num_cells-1 rather than reserving an
+		 * entire byte for each lost packet.
+		 * The reason is that the vector grows in O(burst_length); when
+		 * it grows too large there will no room left for the payload.
+		 * This is a trade-off: if a few packets out of the burst show
+		 * up later, their state will not be changed; it is simply too
+		 * costly to reshuffle/reallocate/copy the buffer each time.
+		 * Should such problems persist, we will need to switch to a
+		 * different underlying data structure.
+		 */
+		for (num_packets = num_cells = 1; lost_packets; ++num_cells) {
+			u8 len = min(lost_packets, (u32)DCCPAV_MAX_RUNLEN);
+
+			av->av_buf_head = dccp_ackvec_idx_sub(av->av_buf_head, 1);
+			av->av_buf[av->av_buf_head] = DCCPAV_NOT_RECEIVED | len;
+
+			lost_packets -= len;
+		}
+	}
+
+	if (num_cells + dccp_ackvec_buflen(av) >= DCCPAV_MAX_ACKVEC_LEN) {
 		DCCP_CRIT("Ack Vector buffer overflow: dropping old entries\n");
 		av->av_overflow = true;
 	}
-- 
