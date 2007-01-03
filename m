From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:08:18 +0000
Subject: [PATCH 4/5][REVISED]: Fix for follows48
Message-Id: <200701031308.19033@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Fix for follows48

The follows48 relation identifies whether 48-bit sequence number
x is the direct successor of y. Currently, it does not handle cases
of the following type correctly:

	follows48(0x(prefix)10000LL, 0x(prefix)0FFFFLL)

where prefix is an arbitrary hex sequence of up to 7 digits.

This is fixed by reusing the new dccp_delta_seqno function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -144,9 +144,7 @@ static inline u64 max48(const u64 seq1, 
 /* is seq1 next seqno after seq2 */
 static inline int follows48(const u64 seq1, const u64 seq2)
 {
-	int diff = (seq1 & 0xFFFF) - (seq2 & 0xFFFF);
-
-	return diff=1;
+	return dccp_delta_seqno(seq2, seq1) = 1;
 }
 
 enum {
