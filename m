From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:08:23 +0000
Subject: [PATCH 5/5][REVISED]: Introduce macro for incrementing modulo-48
Message-Id: <200701031308.24007@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Introduce macro for incrementing modulo-48

Problem: DCCP sequence numbers are mostly stored in 48-bit bitfields
         which are acommodated within an u64 number. For these fields,
         dccp_inc_seqno() can not be used since it takes a u64 pointer.

Fix:     Solved by introducing an INC48() macro to increment modulo-2^48.
Note:    This macro can be used in several places within the ccid3 code.
         However, these changes affect others in turn and therefore require
	 a separate patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -102,6 +102,7 @@ extern int  sysctl_dccp_tx_qlen;
 #define TO_UNSIGNED48(x) (((x) >= 0)?	       (x) :  COMPLEMENT48(-(x)))
 #define ADD48(a, b)	 (((a) + (b)) & DCCP_MAX_SEQNO)
 #define SUB48(a, b)	 ADD48((a), COMPLEMENT48(b))
+#define INC48(seqno)	 seqno = ADD48(seqno, 1)
 
 static inline void dccp_set_seqno(u64 *seqno, u64 value)
 {
@@ -110,7 +111,7 @@ static inline void dccp_set_seqno(u64 *s
 
 static inline void dccp_inc_seqno(u64 *seqno)
 {
-	*seqno = ADD48(*seqno, 1);
+	INC48(*seqno);
 }
 
 /* return > 0 if seqno1 is `before' seqno2, <= 0 otherwise */
