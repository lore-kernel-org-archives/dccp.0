From: Jakub Kicinski <kuba@kernel.org>
Date: Wed, 26 Jan 2022 19:11:03 +0000
Subject: [PATCH net-next 09/15] dccp: remove max48()
Message-Id: <20220126191109.2822706-10-kuba@kernel.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Not used since v2.6.37.

Signed-off-by: Jakub Kicinski <kuba@kernel.org>
---
CC: rdunlap@infradead.org
CC: ncardwell@google.com
CC: edumazet@google.com
CC: dccp@vger.kernel.org
---
 net/dccp/dccp.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 5183e627468d..671c377f0889 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -136,11 +136,6 @@ static inline int between48(const u64 seq1, const u64 seq2, const u64 seq3)
 	return (seq3 << 16) - (seq2 << 16) >= (seq1 << 16) - (seq2 << 16);
 }
 
-static inline u64 max48(const u64 seq1, const u64 seq2)
-{
-	return after48(seq1, seq2) ? seq1 : seq2;
-}
-
 /**
  * dccp_loss_count - Approximate the number of lost data packets in a burst loss
  * @s1:  last known sequence number before the loss ('hole')
-- 
2.34.1
