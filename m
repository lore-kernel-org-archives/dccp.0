From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 13 Dec 2007 15:05:57 +0000
Subject: [PATCH 04/12] [DCCP]: Support for server holding timewait state
Message-Id: <1197558365-31134-5-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This adds a socket option and signalling support for the case where the server
holds timewait state on closing the connection, as described in RFC 4340, 8.3.

Since holding timewait state at the server is the non-usual case, it is enabled
via a socket option. Documentation for this socket option has been added.

The setsockopt statement has been made resilient against different possible cases
of expressing boolean `true' values using a suggestion by Ian McDonald.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 Documentation/networking/dccp.txt |    6 ++++++
 include/linux/dccp.h              |    3 +++
 net/dccp/output.c                 |    6 ++++--
 net/dccp/proto.c                  |   13 ++++++++++++-
 4 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index d76905a..39131a3 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -57,6 +57,12 @@ can be set before calling bind().
 DCCP_SOCKOPT_GET_CUR_MPS is read-only and retrieves the current maximum packet
 size (application payload size) in bytes, see RFC 4340, section 14.
 
+DCCP_SOCKOPT_SERVER_TIMEWAIT enables the server (listening socket) to hold
+timewait state when closing the connection (RFC 4340, 8.3). The usual case is
+that the closing server sends a CloseReq, whereupon the client holds timewait
+state. When this boolean socket option is on, the server sends a Close instead
+and will enter TIMEWAIT. This option must be set after accept() returns.
+
 DCCP_SOCKOPT_SEND_CSCOV and DCCP_SOCKOPT_RECV_CSCOV are used for setting the
 partial checksum coverage (RFC 4340, sec. 9.2). The default is that checksums
 always cover the entire packet and that only fully covered application data is
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 312b989..c676021 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -205,6 +205,7 @@ struct dccp_so_feat {
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
 #define DCCP_SOCKOPT_GET_CUR_MPS	5
+#define DCCP_SOCKOPT_SERVER_TIMEWAIT	6
 #define DCCP_SOCKOPT_SEND_CSCOV		10
 #define DCCP_SOCKOPT_RECV_CSCOV		11
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
@@ -492,6 +493,7 @@ struct dccp_ackvec;
  * @dccps_role - role of this sock, one of %dccp_role
  * @dccps_hc_rx_insert_options - receiver wants to add options when acking
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
+ * @dccps_server_timewait - server holds timewait state on close (RFC 4340, 8.3)
  * @dccps_xmit_timer - timer for when CCID is not ready to send
  * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
  */
@@ -528,6 +530,7 @@ struct dccp_sock {
 	enum dccp_role			dccps_role:2;
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
+	__u8				dccps_server_timewait:1;
 	struct timer_list		dccps_xmit_timer;
 };
 
diff --git a/net/dccp/output.c b/net/dccp/output.c
index e97584a..b2e1791 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -567,8 +567,10 @@ void dccp_send_close(struct sock *sk, const int active)
 
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(skb, sk->sk_prot->max_header);
-	DCCP_SKB_CB(skb)->dccpd_type = dp->dccps_role = DCCP_ROLE_CLIENT ?
-					DCCP_PKT_CLOSE : DCCP_PKT_CLOSEREQ;
+	if (dp->dccps_role = DCCP_ROLE_SERVER && !dp->dccps_server_timewait)
+		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_CLOSEREQ;
+	else
+		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_CLOSE;
 
 	if (active) {
 		dccp_write_xmit(sk, 1);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 8a73c8f..cc87c50 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -551,6 +551,12 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 						     (struct dccp_so_feat __user *)
 						     optval);
 		break;
+	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
+		if (dp->dccps_role != DCCP_ROLE_SERVER)
+			err = -EOPNOTSUPP;
+		else
+			dp->dccps_server_timewait = (val != 0);
+		break;
 	case DCCP_SOCKOPT_SEND_CSCOV:	/* sender side, RFC 4340, sec. 9.2 */
 		if (val < 0 || val > 15)
 			err = -EINVAL;
@@ -653,6 +659,10 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 		val = dp->dccps_mss_cache;
 		len = sizeof(val);
 		break;
+	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
+		val = dp->dccps_server_timewait;
+		len = sizeof(val);
+		break;
 	case DCCP_SOCKOPT_SEND_CSCOV:
 		val = dp->dccps_pcslen;
 		len = sizeof(val);
@@ -918,7 +928,8 @@ static void dccp_terminate_connection(struct sock *sk)
 	case DCCP_OPEN:
 		dccp_send_close(sk, 1);
 
-		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
+		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER &&
+		    !dccp_sk(sk)->dccps_server_timewait)
 			next_state = DCCP_ACTIVE_CLOSEREQ;
 		else
 			next_state = DCCP_CLOSING;
-- 
1.5.3.4

