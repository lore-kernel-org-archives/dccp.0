From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 12 Oct 2010 05:15:49 +0000
Subject: [PATCH 4/6] dccp: generalise data-loss condition
Message-Id: <1286860551-6809-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>

This patch generalises the task of determining data loss from RFC 4340, 7.7.1.

Let S_A, S_B be sequence numbers such that S_B is "after" S_A, and let
N_B be the NDP count of packet S_B. Then, using modulo-2^48 arithmetic,
 D = S_B - S_A - 1  is an upper bound of the number of lost data packets,
 D - N_B            is an approximation of the number of lost data packets
                    (there are cases where this is not exact).

The patch implements this as
 dccp_loss_count(S_A, S_B, N_B) := max(S_B - S_A - 1 - N_B, 0)

Signed-off-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Signed-off-by: Erivaldo Xavier <desadoc@gmail.com>
Signed-off-by: Leandro Sales <leandroal@gmail.com>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -153,18 +153,27 @@ static inline u64 max48(const u64 seq1, const u64 seq2)
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
