From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 08 Jul 2007 11:41:11 +0000
Subject: [PATCH 7/8]: Remove unused inline function
Message-Id: <200707081241.11471@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Remove unused inline function

The function follows48(), which is a special-case of dccp_delta_seqno(),
is nowhere used in the DCCP code, thus removed by this patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    6 ------
 1 file changed, 6 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -145,12 +145,6 @@ static inline u64 max48(const u64 seq1, 
 	return after48(seq1, seq2) ? seq1 : seq2;
 }
 
-/* is seq1 next seqno after seq2 */
-static inline int follows48(const u64 seq1, const u64 seq2)
-{
-	return dccp_delta_seqno(seq2, seq1) = 1;
-}
-
 enum {
 	DCCP_MIB_NUM = 0,
 	DCCP_MIB_ACTIVEOPENS,			/* ActiveOpens */
