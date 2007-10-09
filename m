From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 09 Oct 2007 12:04:56 +0000
Subject: [Announce]: How to add a new CCID for feature negotiation
Message-Id: <200710091304.57011@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This  serves to illustrate how to hook up a new CCID with the new 
feature-negotiation interface, so that the new CCID 

 * is detected for advertising during feature-negotiation,
 * can be queried via getsockopt,
 * can be set via setsockopt,
 * can be negotiated just as any other CCID.

It is done using an existing example, a fully working CCID module, 
CCID Null ("UDP-like", thanks to Arnaldo for the cool name), 
which can be downloaded from

     http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/Null-CCID.diff


Here are the steps.
 

1) Add an entry in the CCID enum in include/linux/dccp.h
--------------------------------------------------------

@@ -173,6 +173,7 @@ enum {
 enum {
 	DCCPC_CCID2 = 2,
 	DCCPC_CCID3 = 3,
+	DCCPC_CCID_NULL = 248,	/* example, for testing */
 };
 

2) Add a Kconfig option (not shown) and add a corresponding line to net/dccp/ccids.c:
-------------------------------------------------------------------------------------
This makes the new CCID `visible' to the sockopt and feature-negotiation infrastructure.

@@ -18,6 +18,9 @@ static u8 builtin_ccids[] = {
 #if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
 	DCCPC_CCID3,
 #endif
+#if defined(CONFIG_IP_DCCP_CCID0) || defined(CONFIG_IP_DCCP_CCID0_MODULE)
+	DCCPC_CCID_NULL,
+#endif
 };
 

3) Add the CCID symbolic name to the validity test in net/dccp/feat.c:
----------------------------------------------------------------------
This test avoids that alien CCIDs are negotiated, so to make a CCID like
CCID_NULL non-alien, it needs to be added in dccp_feat_is_valid_sp_val().

@@ -476,7 +476,8 @@ static u8 dccp_feat_is_valid_sp_val(u8 f
 {
 	switch (feat_num) {
 	case DCCPF_CCID:
-		return (val = DCCPC_CCID2 || val = DCCPC_CCID3);
+		return (val = DCCPC_CCID2 || val = DCCPC_CCID3 ||
+			val = DCCPC_CCID_NULL);
 	/* Type-check Boolean feature values: */
 	case DCCPF_SHORT_SEQNOS:
 	case DCCPF_ECN_INCAPABLE:


4) Add a feature-dependency list to dccp_feat_ccid_deps() in net/dccp/feat.c
----------------------------------------------------------------------------
Many CCIDs have dependencies (CCID2 for instance needs Ack Vectors, the present
Linux implementation of CCID3 relies on NDP count for better accuracy, etc.).

A dependency table ends in both rows with a column that has only zeroes. Since
CCID_NULL is not really a CCID, it has no dependencies, hence the columns in the
table below are empty.

In a real CCID, there would be things like Ack Vector feature etc (check feat.c 
for examples). A dependency table needs to be added in any case. 


@@ -780,9 +781,18 @@ static const struct ccid_dependency *dcc
+	static const struct ccid_dependency ccid0_dependencies[2][1] = {
+		{	/* Receiver-side dependencies: none */
+			{ 0, 0, 0, 0 },
+		},
+		{	/* Sender-side dependencies: none */
+			{ 0, 0, 0, 0 }
+		}
+	};
 	switch (ccid) {
 	case DCCPC_CCID2: return ccid2_dependencies[is_local];
 	case DCCPC_CCID3: return ccid3_dependencies[is_local];
+	case DCCPC_CCID_NULL: return ccid0_dependencies[is_local];
 	default:	  return NULL;	/* other CCIDs: no specifics yet */
 	}
 }


That's all - the new CCID is now ready for use!
