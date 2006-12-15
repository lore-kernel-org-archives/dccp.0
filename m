From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 10:50:46 +0000
Subject: [PATCH 3/8]: Make `before' relation unambiguous
Message-Id: <200612151050.46238@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Make `before' relation unambiguous

Problem:
--------
 before48(a, b) returns the same as before48(b, a) for all a, b which
 are 2^47 apart (modulo-2^48). This is because the difference a-b is used 
 and `true' is returned whenever 2^47 <= a-b <= 2^48-1. This has the
 disadvantage that a positive difference a-b = 2^47 can not be distinguished
 from a negative difference b-a = 2^47. As a result, an ambiguity arises in 
 2^47 cases.

Fix:
----
 The fix is the same as the one suggested for TCP: define a `before' b
 whenever 1 <= b-a <= 2^47-1 (positive signed 48-bit numbers). As a result,
 the ambiguity disappears. (Note: we could have used dccp_delta_seqno, but
 Arnaldo's concept of using shift and subtraction requires fewer operations
 and is thus better).

The patch further defines after48 as a macro, since it is in actual fact just
before48 with the parameters swapped. 

Many thanks to Eddie for help and clarifying discussion with this.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -126,14 +126,11 @@ static inline s64 dccp_delta_seqno(const
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
-	return (s64)((seq1 << 16) - (seq2 << 16)) < 0;
+	return (s64)((seq2 << 16) - (seq1 << 16)) > 0;
 }
 
 /* is seq1 > seq2 ? */
-static inline int after48(const u64 seq1, const u64 seq2)
-{
-	return (s64)((seq2 << 16) - (seq1 << 16)) < 0;
-}
+#define after48(seq1, seq2)	before48((seq2), (seq1))
 
 /* is seq2 <= seq1 <= seq3 ? */
 static inline int between48(const u64 seq1, const u64 seq2, const u64 seq3)
@@ -143,7 +140,7 @@ static inline int between48(const u64 se
 
 static inline u64 max48(const u64 seq1, const u64 seq2)
 {
-	return after48(seq1, seq2) ? seq1 : seq2;
+	return before48(seq2, seq1) ? seq1 : seq2;
 }
 
 /* is seq1 next seqno after seq2 */
