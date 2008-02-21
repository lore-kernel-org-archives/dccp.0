From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Feb 2008 09:09:24 +0000
Subject: [PATCH 06/10] [ACKVEC]: Update code for the Ack Vector input/registration routine
Message-Id: <1203584968-8957-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch uupdates the code which registers new packets as received, using the
new circular buffer interface. It contributes a new algorithm which
	* supports both tail/head pointers and buffer wrap-around and
	* deals with overflow (head/tail move in lock-step).

The updated code is also partioned differently, into
	1. dealing with the empty buffer,
	2. adding new packets into non-empty buffer,
	3. reserving space when encountering a `hole' in the sequence space,
	4. updating old state and deciding when old state is irrelevant.

Protection against large burst losses: With regard to (3), it is too costly to
reserve space when there are large bursts of losses. When bursts get too large,
the code does no longer reserve space and just fills in cells normally. This
measure reduces space consumption by a factor of 63.

The code reuses in part the previous implementation by Arnaldo de Melo.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c |  150 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/ackvec.h |    9 +++
 2 files changed, 159 insertions(+), 0 deletions(-)

--- a/net/dccp/ackvec.h
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
@@ -115,6 +118,7 @@ extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
 			     u64 *ackno, const u8 opt,
 			     const u8 *value, const u8 len);
 
+extern void dccp_ackvec_input(struct dccp_ackvec *av, u64 seqno, u8 state);
 extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
 extern void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
 extern u16  dccp_ackvec_buflen(const struct dccp_ackvec *av);
@@ -142,6 +146,11 @@ static inline void dccp_ackvec_free(struct dccp_ackvec *av)
 {
 }
 
+static inline void dccp_ackvec_input(struct dccp_ackvec *av, u64 seq, u8 state)
+{
+
+}
+
 static inline int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 				  const u64 ackno, const u8 state)
 {
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -134,6 +134,156 @@ u16 dccp_ackvec_buflen(const struct dccp_ackvec *av)
 	return dccp_ackvec_idx_sub(av->av_buf_tail, av->av_buf_head);
 }
 
+/**
+ * dccp_ackvec_update_old  -  Update previous state as per RFC 4340, 11.4.1
+ * @av:		non-empty buffer to update
+ * @distance:   negative or zero distance of @seqno from buf_ackno downward
+ * @seqno:	the (old) sequence number whose record is to be updated
+ * @state:	state in which packet carrying @seqno was received
+ */
+static void dccp_ackvec_update_old(struct dccp_ackvec *av, s64 distance,
+				   u64 seqno, enum dccp_ackvec_states state)
+{
+	u16 ptr = av->av_buf_head;
+
+	BUG_ON(distance > 0);
+	if (unlikely(dccp_ackvec_is_empty(av)))
+		return;
+
+	do {
+		u8 runlen = dccp_ackvec_runlen(av->av_buf + ptr);
+
+		if (distance + runlen >= 0) {
+			/*
+			 * Only update the state if packet has not been received
+			 * yet. This is OK as per the second table in RFC 4340,
+			 * 11.4.1; i.e. here we are using the following table:
+			 *                     RECEIVED
+			 *                      0   1   3
+			 *              S     +---+---+---+
+			 *              T   0 | 0 | 0 | 0 |
+			 *              O     +---+---+---+
+			 *              R   1 | 1 | 1 | 1 |
+			 *              E     +---+---+---+
+			 *              D   3 | 0 | 1 | 3 |
+			 *                    +---+---+---+
+			 * The "Not Received" state was set by reserve_seats().
+			 */
+			if (av->av_buf[ptr] = DCCPAV_NOT_RECEIVED)
+				av->av_buf[ptr] = state;
+			else
+				dccp_pr_debug("Not changing %llu state to %u\n",
+					      (unsigned long long)seqno, state);
+			break;
+		}
+
+		distance += runlen + 1;
+		ptr	  = dccp_ackvec_idx_add(ptr, 1);
+
+	} while (ptr != av->av_buf_tail);
+}
+
+/* Mark @num entries after buf_head as "Not yet received". */
+static void dccp_ackvec_reserve_seats(struct dccp_ackvec *av, u16 num)
+{
+	u16 start = dccp_ackvec_idx_add(av->av_buf_head, 1),
+	    len	  = DCCPAV_MAX_ACKVEC_LEN - start;
+
+	/* check for buffer wrap-around */
+	if (num > len) {
+		memset(av->av_buf + start, DCCPAV_NOT_RECEIVED, len);
+		start = 0;
+		num  -= len;
+	}
+	if (num)
+		memset(av->av_buf + start, DCCPAV_NOT_RECEIVED, num);
+}
+
+/**
+ * dccp_ackvec_add_new  -  Record one or more new entries in Ack Vector buffer
+ * @av:		 container of buffer to update (can be empty or non-empty)
+ * @num_packets: number of packets to register (must be >= 1)
+ * @seqno:	 sequence number of the first packet in @num_packets
+ * @state:	 state in which packet carrying @seqno was received
+ */
+static void dccp_ackvec_add_new(struct dccp_ackvec *av, u32 num_packets,
+				u64 seqno, enum dccp_ackvec_states state)
+{
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
+		DCCP_CRIT("Ack Vector buffer overflow: dropping old entries\n");
+		av->av_overflow = true;
+	}
+
+	av->av_buf_head = dccp_ackvec_idx_sub(av->av_buf_head, num_packets);
+	if (av->av_overflow)
+		av->av_buf_tail = av->av_buf_head;
+
+	av->av_buf[av->av_buf_head] = state;
+	av->av_buf_ackno	    = seqno;
+
+	if (num_packets > 1)
+		dccp_ackvec_reserve_seats(av, num_packets - 1);
+}
+
+/**
+ * dccp_ackvec_input  -  Register incoming packet in the buffer
+ * @av:		buffer/records to update
+ * @seqno:	sequence number to register as received
+ * @state:	how packet with @seqno was received, one of %dccp_ackvec_states
+ */
+void dccp_ackvec_input(struct dccp_ackvec *av, u64 seqno, u8 state)
+{
+	if (dccp_ackvec_is_empty(av)) {
+		dccp_ackvec_add_new(av, 1, seqno, state);
+		av->av_tail_ackno = seqno;
+
+	} else {
+		s64 num_packets = dccp_delta_seqno(av->av_buf_ackno, seqno);
+		u8 *current_head = av->av_buf + av->av_buf_head;
+
+		if (num_packets = 1 &&
+		    dccp_ackvec_state(current_head) = state &&
+		    dccp_ackvec_runlen(current_head) < DCCPAV_MAX_RUNLEN) {
+
+			*current_head   += 1;
+			av->av_buf_ackno = seqno;
+
+		} else if (num_packets > 0) {
+			dccp_ackvec_add_new(av, num_packets, seqno, state);
+		} else {
+			dccp_ackvec_update_old(av, num_packets, seqno, state);
+		}
+	}
+}
+
 /*
  * If several packets are missing, the HC-Receiver may prefer to enter multiple
  * bytes with run length 0, rather than a single byte with a larger run length;
