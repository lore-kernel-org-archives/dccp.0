From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 09 Oct 2007 10:45:43 +0000
Subject: [PATCH v2 7/8]: Handle timestamps on Request/Response exchange separately
Message-Id: <200710091145.44028@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a reworked patch, using the suggested static allocation, with the following differences
 * made the field names consistent between request_sock and dccp_sock;
 * since the time between receiving a Timestamp and sending the Timestamp Echo is not huge, it makes
   sense to use dccp_timestamp() instead of ktime; which also halved the size of the field;
 * whitespace adapted to make assignments toe in line;
 * added a warning when 0-valued timestamps arrive, since we use this to test whether one was present.

I have tested this for functioning in two different environments.

----------------------------------> Patch v2 <------------------------------------------------------------
[DCCP]: Handle timestamps on Request/Response exchange separately

In DCCP, timestamps can occur on packets anytime, CCID3 uses a timestamp(/echo) on the Request/Response
exchange. This patch addresses the following situation:
	* timestamps are recorded on the listening socket;
	* Responses are sent from dccp_request_sockets;
	* suppose two connections reach the listening socket with very small time in between:
	* the first timestamp value gets overwritten by the second connection request.

This is not really good, so this patch separates timestamps into
 * those which are received by the server during the initial handshake (on dccp_request_sock);
 * those which are received by the client or the client after connection establishment.

As before, a timestamp of 0 is regarded as indicating that no (meaningful) timestamp has been
received (in addition, a warning message is printed if hosts send 0-valued timestamps).

The timestamp-echoing now works as follows:
 * when a timestamp is present on the initial Request, it is placed into dreq, due to the
   call to dccp_parse_options in dccp_v{4,6}_conn_request;
 * when a timestamp is present on the Ack leading from RESPOND => OPEN, it is copied over
   from the request_sock into the child cocket in dccp_create_openreq_child;
 * timestamps received on an (established) dccp_sock are treated as before.

Since Elapsed Time is measured in hundredths of milliseconds (13.2), the new dccp_timestamp()
function is used, as it is expected that the time between receiving the timestamp and 
sending the timestamp echo will be very small against the wrap-around time. As a byproduct,
this allows smaller timestamping-time fields.

Furthermore, inserting the Timestamp Echo option has been taken out of the block starting with 
'!dccp_packet_without_ack()', since Timestamp Echo can be carried on any packet (5.8 and 13.3).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   16 ++++++++++++--
 net/dccp/minisocks.c |   21 +++++++++++--------
 net/dccp/options.c   |   56 ++++++++++++++++++++++++++++++++-------------------
 3 files changed, 63 insertions(+), 30 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -407,11 +407,23 @@ struct dccp_opt_pend {
 
 extern void dccp_minisock_init(struct dccp_minisock *dmsk);
 
+/**
+ * struct dccp_request_sock  -  represent DCCP-specific connection request
+ * @dreq_inet_rsk: structure inherited from
+ * @dreq_iss: initial sequence number sent on the Response (RFC 4340, 7.1)
+ * @dreq_isr: initial sequence number received on the Request
+ * @dreq_service: service code present on the Request (there is just one)
+ * The following two fields are analogous to the ones in dccp_sock:
+ * @dreq_timestamp_echo: last received timestamp to echo (13.1)
+ * @dreq_timestamp_echo: the time of receiving the last @dreq_timestamp_echo
+ */
 struct dccp_request_sock {
 	struct inet_request_sock dreq_inet_rsk;
 	__u64			 dreq_iss;
 	__u64			 dreq_isr;
 	__be32			 dreq_service;
+	__u32			 dreq_timestamp_echo;
+	__u32			 dreq_timestamp_time;
 };
 
 static inline struct dccp_request_sock *dccp_rsk(const struct request_sock *req)
@@ -477,8 +489,8 @@ struct dccp_ackvec;
  * @dccps_gar - greatest valid ack number received on a non-Sync; initialized to %dccps_iss
  * @dccps_service - first (passive sock) or unique (active sock) service code
  * @dccps_service_list - second .. last service code on passive socket
- * @dccps_timestamp_time - time of latest TIMESTAMP option
  * @dccps_timestamp_echo - latest timestamp received on a TIMESTAMP option
+ * @dccps_timestamp_time - time of receiving latest @dccps_timestamp_echo
  * @dccps_l_ack_ratio - feature-local Ack Ratio
  * @dccps_r_ack_ratio - feature-remote Ack Ratio
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
@@ -514,8 +526,8 @@ struct dccp_sock {
 	__u64				dccps_gar;
 	__be32				dccps_service;
 	struct dccp_service_list	*dccps_service_list;
-	ktime_t				dccps_timestamp_time;
 	__u32				dccps_timestamp_echo;
+	__u32				dccps_timestamp_time;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
 	__u16				dccps_pcslen;
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -158,16 +158,27 @@ int dccp_parse_options(struct sock *sk, 
 		case DCCPO_TIMESTAMP:
 			if (len != 4)
 				goto out_invalid_option;
-
+			/*
+			 * RFC 4340 13.1: "The precise time corresponding to
+			 * Timestamp Value zero is not specified". We use
+			 * zero to indicate absence of a meaningful timestamp.
+			 */
 			opt_val = get_unaligned((u32 *)value);
-			opt_recv->dccpor_timestamp = ntohl(opt_val);
-
-			/* FIXME: if dreq != NULL, don't store this on listening socket */
-			dp->dccps_timestamp_echo = opt_recv->dccpor_timestamp;
-			dp->dccps_timestamp_time = ktime_get_real();
+			if (unlikely(opt_val = 0)) {
+				DCCP_WARN("Timestamp with zero value\n");
+				break;
+			}
 
+			if (dreq != NULL) {
+				dreq->dreq_timestamp_echo = ntohl(opt_val);
+				dreq->dreq_timestamp_time = dccp_timestamp();
+			} else {
+				opt_recv->dccpor_timestamp = (
+				dp->dccps_timestamp_echo = ntohl(opt_val));
+				dp->dccps_timestamp_time = dccp_timestamp();
+			}
 			dccp_pr_debug("%s rx opt: TIMESTAMP=%u, ackno=%llu\n",
-				      dccp_role(sk), opt_recv->dccpor_timestamp,
+				      dccp_role(sk), ntohl(opt_val),
 				      (unsigned long long)
 				      DCCP_SKB_CB(skb)->dccpd_ack_seq);
 			break;
@@ -385,16 +396,24 @@ int dccp_insert_option_timestamp(struct 
 
 EXPORT_SYMBOL_GPL(dccp_insert_option_timestamp);
 
-static int dccp_insert_option_timestamp_echo(struct sock *sk,
+static int dccp_insert_option_timestamp_echo(struct dccp_sock *dp,
+					     struct dccp_request_sock *dreq,
 					     struct sk_buff *skb)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	__be32 tstamp_echo;
-	int len, elapsed_time_len;
 	unsigned char *to;
-	const suseconds_t delta = ktime_us_delta(ktime_get_real(),
-						 dp->dccps_timestamp_time);
-	u32 elapsed_time = delta / 10;
+	u32 elapsed_time, elapsed_time_len, len;
+
+	if (dreq != NULL) {
+		elapsed_time = dccp_timestamp() - dreq->dreq_timestamp_time;
+		tstamp_echo  = htonl(dreq->dreq_timestamp_echo);
+		dreq->dreq_timestamp_echo = 0;
+	} else {
+		elapsed_time = dccp_timestamp() - dp->dccps_timestamp_time;
+		tstamp_echo  = htonl(dp->dccps_timestamp_echo);
+		dp->dccps_timestamp_echo = 0;
+	}
+
 	elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
 	len = 6 + elapsed_time_len;
 
@@ -407,7 +426,6 @@ static int dccp_insert_option_timestamp_
 	*to++ = DCCPO_TIMESTAMP_ECHO;
 	*to++ = len;
 
-	tstamp_echo = htonl(dp->dccps_timestamp_echo);
 	memcpy(to, &tstamp_echo, 4);
 	to += 4;
 
@@ -419,8 +437,6 @@ static int dccp_insert_option_timestamp_
 		memcpy(to, &var32, 4);
 	}
 
-	dp->dccps_timestamp_echo = 0;
-	dp->dccps_timestamp_time = ktime_set(0, 0);
 	return 0;
 }
 
@@ -529,10 +545,6 @@ int dccp_insert_options(struct sock *sk,
 		    dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
 		    dccp_insert_option_ackvec(sk, skb))
 			return -1;
-
-		if (dp->dccps_timestamp_echo != 0 &&
-		    dccp_insert_option_timestamp_echo(sk, skb))
-			return -1;
 	}
 
 	if (dp->dccps_hc_rx_insert_options) {
@@ -556,6 +568,10 @@ int dccp_insert_options(struct sock *sk,
 	    dccp_insert_option_timestamp(sk, skb))
 		return -1;
 
+	if (dp->dccps_timestamp_echo != 0 &&
+	    dccp_insert_option_timestamp_echo(dp, NULL, skb))
+		return -1;
+
 	/* XXX: insert other options when appropriate */
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len != 0) {
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -117,11 +117,13 @@ struct sock *dccp_create_openreq_child(s
 		struct dccp_sock *newdp = dccp_sk(newsk);
 		struct dccp_minisock *newdmsk = dccp_msk(newsk);
 
-		newdp->dccps_role	   = DCCP_ROLE_SERVER;
-		newdp->dccps_hc_rx_ackvec  = NULL;
-		newdp->dccps_service_list  = NULL;
-		newdp->dccps_service	   = dreq->dreq_service;
-		newicsk->icsk_rto	   = DCCP_TIMEOUT_INIT;
+		newdp->dccps_role	    = DCCP_ROLE_SERVER;
+		newdp->dccps_hc_rx_ackvec   = NULL;
+		newdp->dccps_service_list   = NULL;
+		newdp->dccps_service	    = dreq->dreq_service;
+		newdp->dccps_timestamp_echo = dreq->dreq_timestamp_echo;
+		newdp->dccps_timestamp_time = dreq->dreq_timestamp_time;
+		newicsk->icsk_rto	    = DCCP_TIMEOUT_INIT;
 
 		if (dccp_feat_clone(sk, newsk))
 			goto out_free;
@@ -303,9 +305,12 @@ EXPORT_SYMBOL_GPL(dccp_reqsk_send_ack);
 
 void dccp_reqsk_init(struct request_sock *req, struct sk_buff *skb)
 {
-	inet_rsk(req)->rmt_port = dccp_hdr(skb)->dccph_sport;
-	inet_rsk(req)->acked	= 0;
-	req->rcv_wnd		= sysctl_dccp_feat_sequence_window;
+	struct dccp_request_sock *dreq = dccp_rsk(req);
+
+	inet_rsk(req)->rmt_port	  = dccp_hdr(skb)->dccph_sport;
+	inet_rsk(req)->acked	  = 0;
+	req->rcv_wnd		  = sysctl_dccp_feat_sequence_window;
+	dreq->dreq_timestamp_echo = 0;
 }
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_init);
