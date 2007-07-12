From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Jul 2007 14:26:59 +0000
Subject: [PATCH 9/10]: Support for server holding timewait state
Message-Id: <200707121526.59139@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Support for server holding timewait state

This adds a socket option and signalling support for the case where the server
holds timewait state on closing the connection, as described in RFC 4340, 8.3.

Since holding timewait state at the server is the non-usual case, it is enabled
via a socket option. Documentation for this socket option has been added.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>     
---
 Documentation/networking/dccp.txt |    6 ++++++
 include/linux/dccp.h              |    3 +++
 net/dccp/output.c                 |    6 ++++--
 net/dccp/proto.c                  |   13 ++++++++++++-
 4 files changed, 25 insertions(+), 3 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -46,6 +46,12 @@ can be set before calling bind().
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
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -554,8 +554,10 @@ void dccp_send_close(struct sock *sk, co
 
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
@@ -494,6 +495,7 @@ struct dccp_ackvec;
  * @dccps_role - role of this sock, one of %dccp_role
  * @dccps_hc_rx_insert_options - receiver wants to add options when acking
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
+ * @dccps_server_timewait - server holds timewait state on close (RFC 4340, 8.3)
  * @dccps_xmit_timer - timer for when CCID is not ready to send
  * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
  */
@@ -531,6 +533,7 @@ struct dccp_sock {
 	enum dccp_role			dccps_role:2;
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
+	__u8				dccps_server_timewait:1;
 	struct timer_list		dccps_xmit_timer;
 };
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -497,6 +497,12 @@ static int do_dccp_setsockopt(struct soc
 						     (struct dccp_so_feat __user *)
 						     optval);
 		break;
+	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
+		if (dp->dccps_role != DCCP_ROLE_SERVER)
+			err = -EOPNOTSUPP;
+		else
+			dp->dccps_server_timewait = (val > 0);
+		break;
 	case DCCP_SOCKOPT_SEND_CSCOV:	/* sender side, RFC 4340, sec. 9.2 */
 		if (val < 0 || val > 15)
 			err = -EINVAL;
@@ -599,6 +605,10 @@ static int do_dccp_getsockopt(struct soc
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
@@ -897,7 +907,8 @@ static void dccp_handle_close(struct soc
 		 */
 		dccp_send_close(sk, 1);
 
-		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
+		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER &&
+		    ! dccp_sk(sk)->dccps_server_timewait	  )
 			next_state = DCCP_CLOSEREQ;
 		else
 			next_state = DCCP_CLOSING;
