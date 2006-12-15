From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 10:50:08 +0000
Subject: [PATCH 2/8]: Signed variant of dccp_delta_seqno
Message-Id: <200612151050.08430@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Make dccp_delta_seqno return signed numbers

Problem:
--------
 Using dccp_delta_seqno(a, b) produces unusable results when (by accident or
 coincidence) sequence number b precedes a. 
 If e.g. a and b are merely reordered and have a distance 1, their delta_seqno
 is 2^48-1, which would indicate a loss of 2^48-2 packets. 

Fix:
----
 The fix is by using signed 48-bit arithmetic:
  * dccp_delta_seqno(a, b) returns > 0 as before if a is `before' b
  * it returns 0 if a = b
  * if b precedes a, it returns a value less than 0
  * implements http://www.mail-archive.com/dccp@vger.kernel.org/msg01153.html

 Furthermore, the patch adds some useful constants and macros for 48-bit 
 sequence number arithmetic.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	
---
 net/dccp/dccp.h |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -98,7 +98,11 @@ extern int  sysctl_dccp_tx_qlen;
 #define S48_NEG_MIN	0x800000000000LL		/* 2^47	    */
 #define DCCP_MAX_SEQNO	0xFFFFFFFFFFFFLL		/* 2^48 - 1 */
 #define COMPLEMENT48(x) (0x1000000000000LL - (x))	/* 2^48 - x */
-
+#define TO_SIGNED48(x)	 (((x) < S48_NEG_MIN)? (x) : -COMPLEMENT48( (x)))
+#define TO_UNSIGNED48(x) (((x) >= 0)?	       (x) :  COMPLEMENT48(-(x)))
+#define _add48(a, b)	 (((a) + (b)) & DCCP_MAX_SEQNO)
+#define _sub48(a, b)	 _add48((a), COMPLEMENT48((b)))
+
 static inline void dccp_set_seqno(u64 *seqno, u64 value)
 {
 	*seqno = value & DCCP_MAX_SEQNO;
@@ -111,9 +115,12 @@ static inline void add48(u64 *seqno, u64
 #define sub48(seqno, decr)	add48(seqno, COMPLEMENT48((decr)))
 #define dccp_inc_seqno(seqno)	add48(seqno, 1)
 
-static inline u64 dccp_delta_seqno(u64 seqno1, u64 seqno2)
+/* return > 0 if seqno1 is `before' seqno2, <= 0 otherwise */
+static inline s64 dccp_delta_seqno(const u64 seqno1, const u64 seqno2)
 {
-	return ((seqno2 << 16) - (seqno1 << 16)) >> 16;
+	u64 delta = _sub48(seqno2, seqno1);
+
+	return TO_SIGNED48(delta);
 }
 
 /* is seq1 < seq2 ? */
