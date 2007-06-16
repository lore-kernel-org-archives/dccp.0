From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:39:07 +0000
Subject: [PATCH 02/10] Fix dccp_sum_coverage
Message-Id: <20070616033907.GH24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When compiling with EXTRA_CFLAGS=-W notice that we have signed/unsigned issue
in dccp.h.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index d8ad27b..e2d74cd 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -184,7 +184,7 @@ DECLARE_SNMP_STAT(struct dccp_mib, dccp_statistics);
 /*
  * 	Checksumming routines
  */
-static inline int dccp_csum_coverage(const struct sk_buff *skb)
+static inline unsigned int dccp_csum_coverage(const struct sk_buff *skb)
 {
 	const struct dccp_hdr* dh = dccp_hdr(skb);
 
@@ -195,7 +195,7 @@ static inline int dccp_csum_coverage(const struct sk_buff *skb)
 
 static inline void dccp_csum_outgoing(struct sk_buff *skb)
 {
-	int cov = dccp_csum_coverage(skb);
+	unsigned int cov = dccp_csum_coverage(skb);
 
 	if (cov >= skb->len)
 		dccp_hdr(skb)->dccph_cscov = 0;
-- 
1.5.0.6

