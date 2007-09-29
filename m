From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:38:06 +0000
Subject: [PATCH 02/13] [DCCP]: Add socket option to query the current MPS
Message-Id: <20070929153806.GG23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This enables applications to query the current value of the Maximum Packet
Size via a socket option, suggested as a SHOULD in (RFC 4340, p. 102).

This socket option is useful to avoid the annoying bail-out via `-EMSGSIZE'.
In particular, as fragmentation is not currently supported (and its use is
partly discouraged in RFC 4340).

With this option, it is possible to size buffers accordingly, e.g.

	int buflen = dccp_get_cur_mps(sockfd);

	/* or */
	if (msgsize > dccp_get_cur_mps(sockfd))
		die("message is too large for this path");

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 Documentation/networking/dccp.txt |    3 +++
 include/linux/dccp.h              |    1 +
 net/dccp/proto.c                  |    4 ++++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index 477026a..f915718 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -41,6 +41,9 @@ the socket will fall back to 0 (which means that no meaningful service code
 is present). Connecting sockets set at most one service option; for
 listening sockets, multiple service codes can be specified.
 
+DCCP_SOCKOPT_GET_CUR_MPS is read-only and retrieves the current maximum packet
+size (application payload size) in bytes, see RFC 4340, section 14.
+
 DCCP_SOCKOPT_SEND_CSCOV and DCCP_SOCKOPT_RECV_CSCOV are used for setting the
 partial checksum coverage (RFC 4340, sec. 9.2). The default is that checksums
 always cover the entire packet and that only fully covered application data is
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 4ed82e2..0e44a3e 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -202,6 +202,7 @@ struct dccp_so_feat {
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
+#define DCCP_SOCKOPT_GET_CUR_MPS	5
 #define DCCP_SOCKOPT_SEND_CSCOV		10
 #define DCCP_SOCKOPT_RECV_CSCOV		11
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 7e4f54a..c0b685e 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -587,6 +587,10 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_SERVICE:
 		return dccp_getsockopt_service(sk, len,
 					       (__be32 __user *)optval, optlen);
+	case DCCP_SOCKOPT_GET_CUR_MPS:
+		val = dp->dccps_mss_cache;
+		len = sizeof(val);
+		break;
 	case DCCP_SOCKOPT_SEND_CSCOV:
 		val = dp->dccps_pcslen;
 		len = sizeof(val);
-- 
1.5.2.2

