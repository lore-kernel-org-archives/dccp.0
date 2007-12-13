From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 13 Dec 2007 15:05:58 +0000
Subject: [PATCH 05/12] [DCCP]: Collapse repeated `len' statements into one
Message-Id: <1197558365-31134-6-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This replaces 4 individual assignments for `len' with a single
one, placed where the control flow of those 4 leads to.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/proto.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index cc87c50..0bed4a6 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -657,19 +657,15 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
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
@@ -681,6 +677,7 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 		return -ENOPROTOOPT;
 	}
 
+	len = sizeof(val);
 	if (put_user(len, optlen) || copy_to_user(optval, &val, len))
 		return -EFAULT;
 
-- 
1.5.3.4

