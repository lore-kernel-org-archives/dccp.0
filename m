From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 24 Aug 2006 03:21:51 +0000
Subject: [PATCH 3/7] [DCCP]: Introduces follows48 function
Message-Id: <200608241521.52012.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds a new function to see if two sequence numbers follow each other.

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index b8931d3..84b477d 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -81,6 +81,14 @@ static inline u64 max48(const u64 seq1, 
 	return after48(seq1, seq2) ? seq1 : seq2;
 }
 
+/* is seq1 next seqno after seq2 */
+static inline int follows48(const u64 seq1, const u64 seq2)
+{
+	int diff = (seq1 & 0xFFFF) - (seq2 & 0xFFFF);
+	
+	return diff=1;
+}
+
 enum {
 	DCCP_MIB_NUM = 0,
 	DCCP_MIB_ACTIVEOPENS,			/* ActiveOpens */
