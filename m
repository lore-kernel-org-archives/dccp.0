From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 10:50:01 +0000
Subject: [PATCH 1/8]: Sequence number arithmetic
Message-Id: <200612151050.02039@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Sequence number arithmetic

This patch was inspired by Ian McDonald and
 * organizes the sequence arithmetic functions into one corner of dccp.h
 * performs a small modification of dccp_set_seqno to make it more widely reusable
 * adds functions and macros for wider use:
 	--modulo-48 addition and modulo-48 subtraction
	--dccp_inc_seqno now a special case of add48
 	--48 bit complement
   This is needed for the 48-bit sequence arithmetic.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |   43 ++++++++++++++++++++++++-------------------
 1 file changed, 24 insertions(+), 19 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -92,6 +92,30 @@ extern int  sysctl_dccp_feat_send_ack_ve
 extern int  sysctl_dccp_feat_send_ndp_count;
 extern int  sysctl_dccp_tx_qlen;
 
+/*
+ *	48-bit sequence number arithmetic
+ */
+#define S48_NEG_MIN	0x800000000000LL		/* 2^47	    */
+#define DCCP_MAX_SEQNO	0xFFFFFFFFFFFFLL		/* 2^48 - 1 */
+#define COMPLEMENT48(x) (0x1000000000000LL - (x))	/* 2^48 - x */
+
+static inline void dccp_set_seqno(u64 *seqno, u64 value)
+{
+	*seqno = value & DCCP_MAX_SEQNO;
+}
+
+static inline void add48(u64 *seqno, u64 increment)
+{
+	dccp_set_seqno(seqno, *seqno + increment);
+}
+#define sub48(seqno, decr)	add48(seqno, COMPLEMENT48((decr)))
+#define dccp_inc_seqno(seqno)	add48(seqno, 1)
+
+static inline u64 dccp_delta_seqno(u64 seqno1, u64 seqno2)
+{
+	return ((seqno2 << 16) - (seqno1 << 16)) >> 16;
+}
+
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
@@ -313,27 +337,8 @@ static inline int dccp_packet_without_ac
 	return type = DCCP_PKT_DATA || type = DCCP_PKT_REQUEST;
 }
 
-#define DCCP_MAX_SEQNO ((((u64)1) << 48) - 1)
 #define DCCP_PKT_WITHOUT_ACK_SEQ (DCCP_MAX_SEQNO << 2)
 
-static inline void dccp_set_seqno(u64 *seqno, u64 value)
-{
-	if (value > DCCP_MAX_SEQNO)
-		value -= DCCP_MAX_SEQNO + 1;
-	*seqno = value;
-}
-
-static inline u64 dccp_delta_seqno(u64 seqno1, u64 seqno2)
-{
-	return ((seqno2 << 16) - (seqno1 << 16)) >> 16;
-}
-
-static inline void dccp_inc_seqno(u64 *seqno)
-{
-	if (++*seqno > DCCP_MAX_SEQNO)
-		*seqno = 0;
-}
-
 static inline void dccp_hdr_set_seq(struct dccp_hdr *dh, const u64 gss)
 {
 	struct dccp_hdr_ext *dhx = (struct dccp_hdr_ext *)((void *)dh +
