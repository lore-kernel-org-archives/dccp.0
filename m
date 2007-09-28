From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 15:30:30 +0000
Subject: [PATCH 7/9]: Tidy up setsockopt calls
Message-Id: <200709281630.30299@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Tidy up setsockopt calls

This splits the setsockopt calls into two groups, depending on whether an integer
argument (val) is required and whether routines being called do their own locking.

Some options (such as setting the CCID) use u8 rather than int, so that for these
the test with regard to integer-sizeof can not be used.

The second switch-case statement now only has those statements which need locking
and which make use of val.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/proto.c |   39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -461,10 +461,12 @@ static int dccp_setsockopt_change(struct
 	if (val = NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(val, opt.dccpsf_val, opt.dccpsf_len) = 0)
+	if (copy_from_user(val, opt.dccpsf_val, opt.dccpsf_len) = 0) {
+		lock_sock(sk);
 		rc = dccp_feat_register_change(sk, opt.dccpsf_feat, is_local,
 					       val, opt.dccpsf_len);
-
+		release_sock(sk);
+	}
 	kfree(val);
 	return rc;
 }
@@ -510,27 +512,28 @@ static int do_dccp_setsockopt(struct soc
 	struct dccp_sock *dp = dccp_sk(sk);
 	int val, err = 0;
 
-	if (optlen < sizeof(int))
-		return -EINVAL;
-
-	if (get_user(val, (int __user *)optval))
-		return -EFAULT;
-
-	if (optname = DCCP_SOCKOPT_SERVICE)
-		return dccp_setsockopt_service(sk, val, optval, optlen);
-
-	lock_sock(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
 		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
-		err = 0;
-		break;
+		return 0;
 	case DCCP_SOCKOPT_CHANGE_L:
-		err = dccp_setsockopt_change(sk, optval, optlen, true);
-		break;
+		return dccp_setsockopt_change(sk, optval, optlen, true);
 	case DCCP_SOCKOPT_CHANGE_R:
-		err = dccp_setsockopt_change(sk, optval, optlen, false);
+		return dccp_setsockopt_change(sk, optval, optlen, false);
+	default:
+		if (optlen < sizeof(int))
+			return -EINVAL;
+
+		if (get_user(val, (int __user *)optval))
+			return -EFAULT;
+
+		if (optname = DCCP_SOCKOPT_SERVICE)
+			return dccp_setsockopt_service(sk, val, optval, optlen);
 		break;
+	}
+
+	lock_sock(sk);
+	switch (optname) {
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		if (dp->dccps_role != DCCP_ROLE_SERVER)
 			err = -EOPNOTSUPP;
@@ -547,8 +550,8 @@ static int do_dccp_setsockopt(struct soc
 		err = -ENOPROTOOPT;
 		break;
 	}
-
 	release_sock(sk);
+
 	return err;
 }
 
