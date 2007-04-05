From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:37:23 +0000
Subject: [PATCH 40/43]: Collapse repeated `len' statements into one
Message-Id: <200704051637.24027@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Collapse repeated `len' statements into one

This replaces 4 individual assignments for `len' with a single
one, placed where the control flow of those 4 leads to.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/proto.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -601,19 +601,15 @@ static int do_dccp_getsockopt(struct soc
 					       (__be32 __user *)optval, optlen);
 	case DCCP_SOCKOPT_GET_CUR_MPS:
 		val = dp->dccps_mss_cache;
-		len = sizeof(val);
 		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		val = dp->dccps_server_timewait;
-		len = sizeof(val);
 		break;
 	case DCCP_SOCKOPT_SEND_CSCOV:
 		val = dp->dccps_pcslen;
-		len = sizeof(val);
 		break;
 	case DCCP_SOCKOPT_RECV_CSCOV:
 		val = dp->dccps_pcrlen;
-		len = sizeof(val);
 		break;
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
@@ -625,6 +621,7 @@ static int do_dccp_getsockopt(struct soc
 		return -ENOPROTOOPT;
 	}
 
+	len = sizeof(val);
 	if (put_user(len, optlen) || copy_to_user(optval, &val, len))
 		return -EFAULT;
 
