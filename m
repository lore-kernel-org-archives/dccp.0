From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 14:21:24 +0000
Subject: [PATCH 9/11]: Provide documentation for undocumented sockopt struct
Message-Id: <200709271521.24525@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Provide documentation for undocumented sockopt struct

Also changed the type of the value pointer to void*, to enable
passing NN values (up to 48 bit) onto the socket.

FIXME: I think that this struct might be useful for testing, but it
       would be better to phase it out and replace it by proper socket
       options (setsockopt code for the CCID follows in a later patch).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   13 +++++++++----
 net/dccp/proto.c     |    1 -
 2 files changed, 9 insertions(+), 5 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -191,11 +191,16 @@ enum dccp_feature_numbers {
 	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
-/* this structure is argument to DCCP_SOCKOPT_CHANGE_X */
+/**
+ * struct dccp_so_feat  -  setsockopt struct struct for DCCP_SOCKOPT_CHANGE_X
+ * @dccpsf_feat: feature number (from RFC 4340, 6.4 or related)
+ * @dccpsf_val: single u64 NN value or SP value (u8) plus preference list (u8)
+ * @dccpsf_len: length of @dccpsf_val in bytes (ie. 8 when NN, min 1 when SP)
+ */
 struct dccp_so_feat {
-	__u8 dccpsf_feat;
-	__u8 __user *dccpsf_val;
-	__u8 dccpsf_len;
+	__u8		dccpsf_feat;
+	void __user	*dccpsf_val;
+	__u8		dccpsf_len;
 };
 
 /* DCCP socket options */
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -441,7 +441,6 @@ static int dccp_setsockopt_service(struc
 	return 0;
 }
 
-/* byte 1 is feature.  the rest is the preference list */
 static int dccp_setsockopt_change(struct sock *sk, int type,
 				  struct dccp_so_feat __user *optval)
 
