From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 28 Mar 2007 15:15:31 +0000
Subject: [PATCH 1/1][DCCP] getsockopt: Fix DCCP_SOCKOPT_[SEND,RECV]_CSCOV
Message-Id: <20070328151531.GD20303@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

David,

	Please push for 2.6.21 and stable (CCed for good measure).

- Arnaldo

-----------------------------------

We were only checking if there was enough space to put the int, but left len as
specified by the (malicious) user, sigh, fix it by setting len to sizeof(val) and
transfering just one int worth of data, the one asked for.

Also check for negative len values.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index cf28c53..6607b7b 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -575,7 +575,7 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	if (get_user(len, optlen))
 		return -EFAULT;
 
-	if (len < sizeof(int))
+	if (len < (int)sizeof(int))
 		return -EINVAL;
 
 	dp = dccp_sk(sk);
@@ -589,9 +589,11 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 					       (__be32 __user *)optval, optlen);
 	case DCCP_SOCKOPT_SEND_CSCOV:
 		val = dp->dccps_pcslen;
+		len = sizeof(val);
 		break;
 	case DCCP_SOCKOPT_RECV_CSCOV:
 		val = dp->dccps_pcrlen;
+		len = sizeof(val);
 		break;
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
