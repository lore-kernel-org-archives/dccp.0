From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 09 Oct 2007 10:58:13 +0000
Subject: [PATCH 1/1]: Test tree update
Message-Id: <200710091158.13857@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As suggested by Arnaldo, the internal state names are renamed into 
something which less conflicts with other names and which is more
descriptive.

Patch #1: Realises the naming scheme suggested by Arnaldo.

I have added this into the test tree.


There is another update to report, but it is minor (coding style and 
use of enum constants instead of numbers); this affects [PATCH 1/9] --

 [DCCP]: Registration routines for changing feature values


The update is shown below. (Ian, I have kept your Acked-by that you gave).

---------------------> Update of 1/9 <-----------------------------------
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -297,11 +297,12 @@ cloning_failed:
 static u8 dccp_feat_is_valid_nn_val(u8 feat_num, u64 val)
 {
 	switch (feat_num) {
+	case DCCPF_ACK_RATIO:  
 		/* Ack Ratio takes 2-byte integer values (11.3) */
-		case DCCPF_ACK_RATIO:       return (val <= 0xFFFF);
+		return (val <= 0xFFFF);
+	case DCCPF_SEQUENCE_WINDOW:
 		/* Must be between Wmin2 and Wmax=2^46-1 (7.5.2) */
-		case DCCPF_SEQUENCE_WINDOW: return (val >= 32 &&
-						    val <= 0x3FFFFFFFFFFFull);
+		return (val >= 32 && val <= 0x3FFFFFFFFFFFull);
 	}
 	return 0;	/* feature unknown - so we can't tell */
 }
@@ -310,14 +311,18 @@ static u8 dccp_feat_is_valid_nn_val(u8 f
 static u8 dccp_feat_is_valid_sp_val(u8 feat_num, u8 val)
 {
 	switch (feat_num) {
-	case DCCPF_CCID:		return val = 2 || val = 3;
-	case DCCPF_SHORT_SEQNOS:	/* fall through */
-	case DCCPF_ECN_INCAPABLE:	/* fall through */
-	case DCCPF_SEND_ACK_VECTOR:	/* fall through */
-	case DCCPF_SEND_NDP_COUNT:	/* fall through */
-	case DCCPF_DATA_CHECKSUM:	/* fall through */
-	case DCCPF_SEND_LEV_RATE:	return val < 2;
-	case DCCPF_MIN_CSUM_COVER:	return val < 16;
+	case DCCPF_CCID:
+		return (val = DCCPC_CCID2 || val = DCCPC_CCID3);
+	/* Type-check Boolean feature values: */
+	case DCCPF_SHORT_SEQNOS:
+	case DCCPF_ECN_INCAPABLE:
+	case DCCPF_SEND_ACK_VECTOR:
+	case DCCPF_SEND_NDP_COUNT:
+	case DCCPF_DATA_CHECKSUM:
+	case DCCPF_SEND_LEV_RATE:	
+		return val < 2;
+	case DCCPF_MIN_CSUM_COVER:	
+		return val < 16;
 	}
 	return 0;			/* feature unknown */
 }
