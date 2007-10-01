From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:31 +0000
Subject: [PATCH 9/11]: Fill in the Data1..3 fields when option processing encounters option errors
Message-Id: <200710011518.31492@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Fill in the Data1..3 fields when option processing encounters option errors

DCCP provides the Data 1..3 fields in the Reset header to carry information
about why the connection was reset. An earlier patch provided basic support,
this patch extends the capabilities by adding Reset information when processing
erroneous options.
This support will be made use of by the next two patches which process Change/
Confirm feature-negotiation options.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -64,7 +64,7 @@ int dccp_parse_options(struct sock *sk, 
 	unsigned char opt, len;
 	unsigned char *value;
 	u32 elapsed_time, opt_val;
-	int rc;
+	u8 rc = DCCP_RESET_CODE_OPTION_ERROR;
 	int mandatory = 0;
 
 	memset(opt_recv, 0, sizeof(*opt_recv));
@@ -81,16 +81,16 @@ int dccp_parse_options(struct sock *sk, 
 				goto out_invalid_option;
 
 			len = *opt_ptr++;
-			if (len < 3)
-				goto out_invalid_option;
 			/*
 			 * Remove the type and len fields, leaving
 			 * just the value size
 			 */
-			len	-= 2;
 			value	= opt_ptr;
+			len	-= 2;
 			opt_ptr += len;
 
+			if (len = 0)
+				goto out_invalid_option;
 			if (opt_ptr > opt_end)
 				goto out_invalid_option;
 		}
@@ -282,8 +282,14 @@ ignore_option:
 
 out_invalid_option:
 	DCCP_INC_STATS_BH(DCCP_MIB_INVALIDOPT);
-	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_OPTION_ERROR;
-	DCCP_WARN("DCCP(%p): invalid option %d, len=%d", sk, opt, len);
+	DCCP_WARN("DCCP(%p): Option %d (len=%d) error=%u\n", sk, opt, len, rc);
+	DCCP_SKB_CB(skb)->dccpd_reset_code = rc;
+	if (rc = DCCP_RESET_CODE_OPTION_ERROR ||
+	    rc = DCCP_RESET_CODE_MANDATORY_ERROR) {
+		DCCP_SKB_CB(skb)->dccpd_reset_data[0] = opt;
+		DCCP_SKB_CB(skb)->dccpd_reset_data[1] = len > 0? value[0] : 0;
+		DCCP_SKB_CB(skb)->dccpd_reset_data[2] = len > 1? value[1] : 0;
+	}
 	return -1;
 }
 
