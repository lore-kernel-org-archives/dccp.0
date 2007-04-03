From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 03 Apr 2007 09:59:26 +0000
Subject: [PATCH v2]: Add socket option to query the current MPS
Message-Id: <200704031059.27031@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an update on the MPS-via getsockopt patch. I noted I had committed the same sin 
here as fixed last Wednesday by Arnaldo for the CSCOV get/setsockopt patch.

The inter-diff to the previous version of this patch is:

@@ -588,6 +588,7 @@ static int do_dccp_getsockopt(struct soc
                                               (__be32 __user *)optval, optlen);
        case DCCP_SOCKOPT_GET_CUR_MPS:
                val = dp->dccps_mss_cache;
+               len = sizeof(val);
                break;
        case DCCP_SOCKOPT_SEND_CSCOV:
                val = dp->dccps_pcslen;

The v2 patch further applies on top of the CSCOV patch (although I have not yet seen it in 2.6.22).


--------------------------------> Patch v2 <----------------------------------
[DCCP]: Add socket option to query the current MPS

This enables applications to query the current value of the Maximum Packet 
Size via a socket option, suggested as a SHOULD in (RFC 4340, p. 102). 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    3 +++
 include/linux/dccp.h              |    1 +
 net/dccp/proto.c                  |    4 ++++
 3 files changed, 8 insertions(+)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -41,6 +41,9 @@ the socket will fall back to 0 (which me
 is present). Connecting sockets set at most one service option; for
 listening sockets, multiple service codes can be specified.
 
+DCCP_SOCKOPT_GET_CUR_MPS is read-only and retrieves the current maximum packet
+size (application payload size) in bytes, see RFC 4340, section 14.
+
 DCCP_SOCKOPT_SEND_CSCOV and DCCP_SOCKOPT_RECV_CSCOV are used for setting the
 partial checksum coverage (RFC 4340, sec. 9.2). The default is that checksums
 always cover the entire packet and that only fully covered application data is
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -204,6 +204,7 @@ struct dccp_so_feat {
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
+#define DCCP_SOCKOPT_GET_CUR_MPS	5
 #define DCCP_SOCKOPT_SEND_CSCOV		10
 #define DCCP_SOCKOPT_RECV_CSCOV		11
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -586,6 +586,10 @@ static int do_dccp_getsockopt(struct soc
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
