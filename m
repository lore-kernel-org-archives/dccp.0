From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:32:06 +0000
Subject: [PATCH 23/25] Include ccid-4 to be visible for the DCCP feature negotiation mechanism
Message-Id: <200710312132.06341.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-4] Include ccid-4 to be visible for the DCCP feature negotiation mechanism

This patch follow instructions announced by Gerrit and explained in http://www.mail-archive.com/dccp@vger.kernel.org/msg02613.html

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/include/linux/dccp.h
=================================--- leandro.new.orig/include/linux/dccp.h
+++ leandro.new/include/linux/dccp.h
@@ -173,6 +173,7 @@ enum {
 enum {
 	DCCPC_CCID2 = 2,
 	DCCPC_CCID3 = 3,
+	DCCPC_CCID4 = 4,
 };
 
 /* DCCP features (RFC 4340 section 6.4) */
Index: leandro.new/net/dccp/ccid.c
=================================--- leandro.new.orig/net/dccp/ccid.c
+++ leandro.new/net/dccp/ccid.c
@@ -18,6 +18,9 @@ static u8 builtin_ccids[] = {
 #if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
 	DCCPC_CCID3,
 #endif
+#if defined(CONFIG_IP_DCCP_CCID4) || defined(CONFIG_IP_DCCP_CCID4_MODULE)
+	DCCPC_CCID4,
+#endif
 };
 
 static struct ccid_operations *ccids[CCID_MAX];
Index: leandro.new/net/dccp/feat.c
=================================--- leandro.new.orig/net/dccp/feat.c
+++ leandro.new/net/dccp/feat.c
@@ -483,7 +483,8 @@ static u8 dccp_feat_is_valid_sp_val(u8 f
 {
 	switch (feat_num) {
 	case DCCPF_CCID:
-		return (val = DCCPC_CCID2 || val = DCCPC_CCID3);
+		return (val = DCCPC_CCID2 || val = DCCPC_CCID3 ||
+                        val = DCCPC_CCID4);
 	/* Type-check Boolean feature values: */
 	case DCCPF_SHORT_SEQNOS:
 	case DCCPF_ECN_INCAPABLE:
@@ -787,9 +788,65 @@ static const struct ccid_dependency *dcc
 			{ 0, 0, 0, 0 }
 		}
 	};
+	static const struct ccid_dependency ccid4_dependencies[2][5] = {
+		{	/*
+			 * Dependencies of the receiver-side CCID4
+			 */
+			{	/* locally disable Ack Vectors */
+				.dependent_feat	= DCCPF_SEND_ACK_VECTOR,
+				.is_local	= true,
+				.is_mandatory	= false,
+				.val		= 0
+			},
+			{	/* see below why Send Loss Event Rate is on */
+				.dependent_feat	= DCCPF_SEND_LEV_RATE,
+				.is_local	= true,
+				.is_mandatory	= true,
+				.val		= 1
+			},
+			{	/* NDP Count is needed as per RFC 4342, 6.1.1 */
+				.dependent_feat	= DCCPF_SEND_NDP_COUNT,
+				.is_local	= false,
+				.is_mandatory	= true,
+				.val		= 1
+			},
+			{ 0, 0, 0, 0 },
+		},
+		{
+                        /*
+                         * Dependencies of the transmiter-side CCID4
+                         */
+			{
+				.dependent_feat	= DCCPF_SEND_ACK_VECTOR,
+				.is_local	= false,
+				.is_mandatory	= false,
+				.val		= 0
+			},
+			{
+				.dependent_feat	= DCCPF_SEND_LEV_RATE,
+				.is_local	= false,
+				.is_mandatory	= true,
+				.val		= 1
+			},
+			{	/* this CCID does not support Ack Ratio */
+				.dependent_feat	= DCCPF_ACK_RATIO,
+				.is_local	= true,
+				.is_mandatory	= false,
+				.val		= 0
+			},
+			{	/* tell receiver we are sending NDP counts */
+				.dependent_feat	= DCCPF_SEND_NDP_COUNT,
+				.is_local	= true,
+				.is_mandatory	= false,
+				.val		= 1
+			},
+			{ 0, 0, 0, 0 }
+		}
+	};
 	switch (ccid) {
 	case DCCPC_CCID2: return ccid2_dependencies[is_local];
 	case DCCPC_CCID3: return ccid3_dependencies[is_local];
+	case DCCPC_CCID4: return ccid4_dependencies[is_local];
 	default:	  return NULL;	/* other CCIDs: no specifics yet */
 	}
 }
