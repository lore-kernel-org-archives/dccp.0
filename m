From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:08:02 +0000
Subject: [PATCH 1/5][REVISED]: 48-bit sequence number arithmetic
Message-Id: <200701031308.02438@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: 48-bit sequence number arithmetic

This patch 
 * organizes the sequence arithmetic functions into one corner of dccp.h
 * performs a small modification of dccp_set_seqno to make it more widely reusable
   (now it is safe to use any number, since it performs modulo-2^48 assignment)
 * adds functions and generic macros for 48-bit sequence arithmetic:
 	--48 bit complement
 	--modulo-48 addition and modulo-48 subtraction
	--dccp_inc_seqno now a special case of add48

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h |   45 ++++++++++++++++++++++++++-------------------
 1 file changed, 26 insertions(+), 19 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -92,6 +92,32 @@ extern int  sysctl_dccp_feat_send_ack_ve
 extern int  sysctl_dccp_feat_send_ndp_count;
 extern int  sysctl_dccp_tx_qlen;
 
+/*
+ *	48-bit sequence number arithmetic
+ */
+#define S48_NEG_MIN	  0x800000000000LL		/* 2^47	    */
+#define DCCP_MAX_SEQNO	  0xFFFFFFFFFFFFLL		/* 2^48 - 1 */
+#define COMPLEMENT48(x)	 (0x1000000000000LL - (x))	/* 2^48 - x */
+#define TO_SIGNED48(x)	 (((x) < S48_NEG_MIN)? (x) : -COMPLEMENT48( (x)))
+#define TO_UNSIGNED48(x) (((x) >= 0)?	       (x) :  COMPLEMENT48(-(x)))
+#define ADD48(a, b)	 (((a) + (b)) & DCCP_MAX_SEQNO)
+#define SUB48(a, b)	 ADD48((a), COMPLEMENT48(b))
+
+static inline void dccp_set_seqno(u64 *seqno, u64 value)
+{
+	*seqno = value & DCCP_MAX_SEQNO;
+}
+
+static inline void dccp_inc_seqno(u64 *seqno)
+{
+	*seqno = ADD48(*seqno, 1);
+}
+
+static inline u64 dccp_delta_seqno(u64 seqno1, u64 seqno2)
+{
+	return ((seqno2 << 16) - (seqno1 << 16)) >> 16;
+}
+
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
@@ -313,27 +339,8 @@ static inline int dccp_packet_without_ac
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
