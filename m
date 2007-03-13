From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 Mar 2007 11:37:33 +0000
Subject: [PATCH v3]: 1a_simplify_seqno_arithmetic.diff
Message-Id: <200703131137.33202@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorry, missed out one occurrence in ackvec.c. Have compile-tested
this time.

Interdiff v2 .. v3:
@@ -157,7 +157,7 @@ struct dccp_ackvec *dccp_ackvec_alloc(co

        if (av != NULL) {
                av->dccpav_buf_head     = DCCP_MAX_ACKVEC_LEN - 1;
-               av->dccpav_buf_ackno    = DCCP_MAX_SEQNO + 1;
+               av->dccpav_buf_ackno    = UINT48_MAX + 1;
                av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
                av->dccpav_time.tv_sec  = 0;
                av->dccpav_time.tv_usec = 0;

(don't understand: why not use 0)

=============> Patch v3 <======================
[DCCP]: 48-bit sequence number arithmetic

This patch 
 * organizes the sequence arithmetic functions into one corner of dccp.h
 * performs a small modification of dccp_set_seqno to make it more widely reusable
   (now it is safe to use any number, since it performs modulo-2^48 assignment)
 * adds functions and generic macros for 48-bit sequence arithmetic:
 	--48 bit complement
 	--modulo-48 addition and modulo-48 subtraction
	--dccp_inc_seqno now a special case of add48
Constants renamed following a suggestion by Arnaldo. 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ackvec.c |    2 +-
 net/dccp/dccp.h   |   47 +++++++++++++++++++++++++++--------------------
 2 files changed, 28 insertions(+), 21 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -92,6 +92,32 @@ extern int  sysctl_dccp_feat_send_ack_ve
 extern int  sysctl_dccp_feat_send_ndp_count;
 extern int  sysctl_dccp_tx_qlen;
 
+/*
+ *	48-bit sequence number arithmetic (signed and unsigned)
+ */
+#define INT48_MIN	  0x800000000000LL		/* 2^47	    */
+#define UINT48_MAX	  0xFFFFFFFFFFFFLL		/* 2^48 - 1 */
+#define COMPLEMENT48(x)	 (0x1000000000000LL - (x))	/* 2^48 - x */
+#define TO_SIGNED48(x)	 (((x) < INT48_MIN)? (x) : -COMPLEMENT48( (x)))
+#define TO_UNSIGNED48(x) (((x) >= 0)?	     (x) :  COMPLEMENT48(-(x)))
+#define ADD48(a, b)	 (((a) + (b)) & UINT48_MAX)
+#define SUB48(a, b)	 ADD48((a), COMPLEMENT48(b))
+
+static inline void dccp_set_seqno(u64 *seqno, u64 value)
+{
+	*seqno = value & UINT48_MAX;
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
@@ -314,26 +340,7 @@ static inline int dccp_packet_without_ac
 	return type = DCCP_PKT_DATA || type = DCCP_PKT_REQUEST;
 }
 
-#define DCCP_MAX_SEQNO ((((u64)1) << 48) - 1)
-#define DCCP_PKT_WITHOUT_ACK_SEQ (DCCP_MAX_SEQNO << 2)
-
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
+#define DCCP_PKT_WITHOUT_ACK_SEQ (UINT48_MAX << 2)
 
 static inline void dccp_hdr_set_seq(struct dccp_hdr *dh, const u64 gss)
 {
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -157,7 +157,7 @@ struct dccp_ackvec *dccp_ackvec_alloc(co
 
 	if (av != NULL) {
 		av->dccpav_buf_head	= DCCP_MAX_ACKVEC_LEN - 1;
-		av->dccpav_buf_ackno	= DCCP_MAX_SEQNO + 1;
+		av->dccpav_buf_ackno	= UINT48_MAX + 1;
 		av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
 		av->dccpav_time.tv_sec	= 0;
 		av->dccpav_time.tv_usec	= 0;
