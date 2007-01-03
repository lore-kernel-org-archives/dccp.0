From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:08:07 +0000
Subject: [PATCH 2/5][REVISED]: Make dccp_delta_seqno return signed numbers
Message-Id: <200701031308.07932@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Make dccp_delta_seqno return signed numbers

Problem:
--------
 Using dccp_delta_seqno(a, b) produces unusable results when -- by accident
 or coincidence -- sequence number b precedes a.  If e.g. a and b are merely
 reordered and have a distance 1, their delta_seqno is 2^48-1, which would
 indicate a loss of 2^48-2 packets.

Fix:
----
 The fix is by using signed 48-bit arithmetic for dccp_delta_seqno, so that
 dccp_delta_seqno(a, b) returns:
  * > 0 if a is `before' b                OR
  *   0 if a = b                         OR
  * < 0 and > -2^47 if b is `before' a    OR
  * -2^47           if neither a `before' b  nor  b `before' a

 This implements http://www.mail-archive.com/dccp@vger.kernel.org/msg01153.html

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -113,9 +113,12 @@ static inline void dccp_inc_seqno(u64 *s
 	*seqno = ADD48(*seqno, 1);
 }
 
-static inline u64 dccp_delta_seqno(u64 seqno1, u64 seqno2)
+/* return > 0 if seqno1 is `before' seqno2, <= 0 otherwise */
+static inline s64 dccp_delta_seqno(const u64 seqno1, const u64 seqno2)
 {
-	return ((seqno2 << 16) - (seqno1 << 16)) >> 16;
+	u64 delta = SUB48(seqno2, seqno1);
+
+	return TO_SIGNED48(delta);
 }
 
 /* is seq1 < seq2 ? */
