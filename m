From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 13:53:22 +0000
Subject: [PATCH v2 2/11]: Increase the scope of variable-length htonl/ntohl functions
Message-Id: <200710021453.22340@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Revised patch, as a dependency of the previous one. 
Change: now uses DCCP_OPTVAL_MAXLEN to make explicit the dependency of the byte-lengths
        of option values on this constant

-----------------------> Patch v2 <-----------------------------------------
[DCCP]: Increase the scope of variable-length htonl/ntohl functions

This extends the scope of two available functions, encode|decode_value_var,
to work up to 6 (8) bytes, to match maximum requirements in the RFC.

These functions are going to be used both by general option processing and 
feature negotiation code, hence declarations have been put into feat.h.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/feat.h    |    2 ++
 net/dccp/options.c |   21 ++++++++++++++-------
 2 files changed, 16 insertions(+), 7 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -131,4 +131,6 @@ static inline u8 dccp_bytes_per_value(co
 	return value > 0xFFFF ? 4 : (value > 0xFF ? 2 : 1);
 }
 
+extern void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
+extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -23,16 +23,20 @@
 #include "dccp.h"
 #include "feat.h"
 
-static u32 dccp_decode_value_var(const unsigned char *bf, const u8 len)
+u64 dccp_decode_value_var(const u8 *bf, const u8 len)
 {
-	u32 value = 0;
+	u64 value = 0;
 
+	if (len >= DCCP_OPTVAL_MAXLEN)
+		value += ((u64)*bf++) << 40;
+	if (len > 4)
+		value += ((u64)*bf++) << 32;
 	if (len > 3)
-		value += *bf++ << 24;
+		value += ((u64)*bf++) << 24;
 	if (len > 2)
-		value += *bf++ << 16;
+		value += ((u64)*bf++) << 16;
 	if (len > 1)
-		value += *bf++ << 8;
+		value += ((u64)*bf++) << 8;
 	if (len > 0)
 		value += *bf;
 
@@ -288,9 +292,12 @@ out_invalid_option:
 
 EXPORT_SYMBOL_GPL(dccp_parse_options);
 
-static void dccp_encode_value_var(const u32 value, unsigned char *to,
-				  const unsigned int len)
+void dccp_encode_value_var(const u64 value, u8 *to, const u8 len)
 {
+	if (len >= DCCP_OPTVAL_MAXLEN)
+		*to++ = (value & 0xFF0000000000ull) >> 40;
+	if (len > 4)
+		*to++ = (value & 0xFF00000000ull) >> 32;
 	if (len > 3)
 		*to++ = (value & 0xFF000000) >> 24;
 	if (len > 2)
