From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 17 Dec 2007 15:00:19 +0000
Subject: [PATCH 5/5] [DCCP]: Remove unused inline function
Message-Id: <1197903619-12301-6-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

The function follows48(), which is a special-case of dccp_delta_seqno(),
is nowhere used in the DCCP code, thus removed by this patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index b138e20..ebe59d9 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -153,12 +153,6 @@ static inline u64 max48(const u64 seq1, const u64 seq2)
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
-- 
1.5.3.6

