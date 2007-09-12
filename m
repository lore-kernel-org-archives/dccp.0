From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Sep 2007 14:35:11 +0000
Subject: [PATCH 2/5]: Twice the wrong reset code in receiving connection-Requests
Message-Id: <200709121535.11607@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Twice the wrong reset code in receiving connection-Requests

This fixes two bugs in processing of connection-Requests in v{4,6}_conn_request:
 1. Due to using the variable `reset_code', the Reset code generated internally
    by dccp_parse_options() is overwritten with the initialised value ("Too Busy")
    of reset_code, which is not what is intended.
 2. When receiving a connection-Request on a multicast or broadcast address, no
    Reset should be generated, to avoid storms of such packets. Instead of jumping
    to the `drop' label, the v{4,6}_conn_request functions now return 0. Below is
    why in my understanding this is correct:

    When the conn_request function returns < 0, then the caller, dccp_rcv_state_process(),
    returns 1. In all instances where dccp_rcv_state_process is called (dccp_v4_do_rcv, 
    dccp_v6_do_rcv, and dccp_child_process), a return value of != 0 from dccp_rcv_state_process()
    means that a Reset is generated.
    If on the other hand the conn_request function returns 0, the packet is discarded and no 
    Reset is generated. 

Note: There may be a related problem when sending the Response, due to the following.
      	if (dccp_v6_send_response(sk, req, NULL))
		goto drop_and_free;
	/* ... */
	drop_and_free:
     		return -1;
      
      In this case, if send_response fails due to transmission errors, the next thing that is
      generated is a Reset with a code "Too Busy". I haven't been able to conjure up such a
      condition, but it might be good to change the behaviour here also (not done by this patch).
      
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>   
---
 net/dccp/ipv4.c |   11 ++++-------
 net/dccp/ipv6.c |    7 +++----
 2 files changed, 7 insertions(+), 11 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -598,17 +598,14 @@ int dccp_v4_conn_request(struct sock *sk
 	struct dccp_request_sock *dreq;
 	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
-	__u8 reset_code = DCCP_RESET_CODE_TOO_BUSY;
 
 	/* Never answer to DCCP_PKT_REQUESTs send to broadcast or multicast */
 	if (((struct rtable *)skb->dst)->rt_flags &
-	    (RTCF_BROADCAST | RTCF_MULTICAST)) {
-		reset_code = DCCP_RESET_CODE_NO_CONNECTION;
-		goto drop;
-	}
+	    (RTCF_BROADCAST | RTCF_MULTICAST))
+		return 0;	/* discard, don't send a reset here */
 
 	if (dccp_bad_service_code(sk, service)) {
-		reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
+		dcb->dccpd_reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
 		goto drop;
 	}
 	/*
@@ -616,6 +613,7 @@ int dccp_v4_conn_request(struct sock *sk
 	 * limitations, they conserve resources and peer is
 	 * evidently real one.
 	 */
+	dcb->dccpd_reset_code = DCCP_RESET_CODE_TOO_BUSY;
 	if (inet_csk_reqsk_queue_is_full(sk))
 		goto drop;
 
@@ -668,7 +666,6 @@ drop_and_free:
 	reqsk_free(req);
 drop:
 	DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
-	dcb->dccpd_reset_code = reset_code;
 	return -1;
 }
 
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -417,21 +417,21 @@ static int dccp_v6_conn_request(struct s
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
-	__u8 reset_code = DCCP_RESET_CODE_TOO_BUSY;
 
 	if (skb->protocol = htons(ETH_P_IP))
 		return dccp_v4_conn_request(sk, skb);
 
 	if (!ipv6_unicast_destination(skb))
-		goto drop;
+		return 0;	/* discard, don't send a reset here */
 
 	if (dccp_bad_service_code(sk, service)) {
-		reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
+		dcb->dccpd_reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
 		goto drop;
 	}
 	/*
 	 * There are no SYN attacks on IPv6, yet...
 	 */
+	dcb->dccpd_reset_code = DCCP_RESET_CODE_TOO_BUSY;
 	if (inet_csk_reqsk_queue_is_full(sk))
 		goto drop;
 
@@ -491,7 +491,6 @@ drop_and_free:
 	reqsk_free(req);
 drop:
 	DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
-	dcb->dccpd_reset_code = reset_code;
 	return -1;
 }
 
