From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 19 Oct 2009 05:16:42 +0000
Subject: dccp-test-tree [PATCH 1/1]: Count lost data packets in a burst loss
Message-Id: <20091019051642.GA3366@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: Generalise data-loss condition

This patch is thanks to Ivo Calado who had integrated this function into one
of the TFRC-SP patches.

It generalises the task of determining data loss from RFC 43430, 7.7.1.

Let S_A, S_B be sequence numbers such that S_B is "after" S_A, and let
N_B be the NDP count of packet S_B. Then, using module-2^48 arithmetic,
 D = S_B - S_A - 1  is an upper bound of the number of lost data packets,
 D - N_B            is an approximation of the number of lost data packets
                    (there are cases where this is not exact).

The patch implements this as
 dccp_loss_count(S_A, S_B, N_B) := max(S_B - S_A - 1 - N_B, 0)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |   21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -153,18 +153,27 @@ static inline u64 max48(const u64 seq1, 
 }
 
 /**
- * dccp_loss_free  -  Evaluates condition for data loss from RFC 4340, 7.7.1
- * @s1:	 start sequence number
- * @s2:  end sequence number
+ * dccp_loss_count - Approximate the number of lost data packets in a burst loss
+ * @s1:  last known sequence number before the loss ('hole')
+ * @s2:  first sequence number seen after the 'hole'
  * @ndp: NDP count on packet with sequence number @s2
- * Returns true if the sequence range s1...s2 has no data loss.
  */
-static inline bool dccp_loss_free(const u64 s1, const u64 s2, const u64 ndp)
+static inline u64 dccp_loss_count(const u64 s1, const u64 s2, const u64 ndp)
 {
 	s64 delta = dccp_delta_seqno(s1, s2);
 
 	WARN_ON(delta < 0);
-	return (u64)delta <= ndp + 1;
+	delta -= ndp + 1;
+
+	return delta > 0 ? delta : 0;
+}
+
+/**
+ * dccp_loss_free - Evaluate condition for data loss from RFC 4340, 7.7.1
+ */
+static inline bool dccp_loss_free(const u64 s1, const u64 s2, const u64 ndp)
+{
+	return dccp_loss_count(s1, s2, ndp) = 0;
 }
 
 enum {
