From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 14:01:23 +0000
Subject: [PATCH 16/17] [DCCP]: Update code comments for Step 2/3
Message-Id: <200610241501.23442@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Update code comments for Step 2/3

Sorts out the comments for processing steps 2,3 in section 8.5 of RFC 4340.
All comments have been updated against this document, and the reference to
step 2 has been made consistent throughout the files.


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/input.c     |   39 +++++++++++++++++----------------------
 net/dccp/ipv4.c      |   44 ++++++++++++++++++++------------------------
 net/dccp/ipv6.c      |   37 +++++++++++++++++++++++++++++--------
 net/dccp/minisocks.c |   10 +++++-----
 4 files changed, 71 insertions(+), 59 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 1d24881..4024d2b 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -431,29 +431,24 @@ int dccp_rcv_state_process(struct sock *
 
 	/*
 	 *  Step 3: Process LISTEN state
-	 *  	(Continuing from dccp_v4_do_rcv and dccp_v6_do_rcv)
-	 *
 	 *     If S.state = LISTEN,
-	 *	  If P.type = Request or P contains a valid Init Cookie
-	 *	  	option,
-	 *	     * Must scan the packet's options to check for an Init
-	 *		Cookie.  Only the Init Cookie is processed here,
-	 *		however; other options are processed in Step 8.  This
-	 *		scan need only be performed if the endpoint uses Init
-	 *		Cookies *
-	 *	     * Generate a new socket and switch to that socket *
-	 *	     Set S := new socket for this port pair
-	 *	     S.state = RESPOND
-	 *	     Choose S.ISS (initial seqno) or set from Init Cookie
-	 *	     Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
-	 *	     Continue with S.state = RESPOND
-	 *	     * A Response packet will be generated in Step 11 *
-	 *	  Otherwise,
-	 *	     Generate Reset(No Connection) unless P.type = Reset
-	 *	     Drop packet and return
-	 *
-	 * NOTE: the check for the packet types is done in
-	 *	 dccp_rcv_state_process
+	 *	 If P.type = Request or P contains a valid Init Cookie option,
+	 *	      (* Must scan the packet's options to check for Init
+	 *		 Cookies.  Only Init Cookies are processed here,
+	 *		 however; other options are processed in Step 8.  This
+	 *		 scan need only be performed if the endpoint uses Init
+	 *		 Cookies *)
+	 *	      (* Generate a new socket and switch to that socket *)
+	 *	      Set S := new socket for this port pair
+	 *	      S.state = RESPOND
+	 *	      Choose S.ISS (initial seqno) or set from Init Cookies
+	 *	      Initialize S.GAR := S.ISS
+	 *	      Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
+	 *	      Continue with S.state = RESPOND
+	 *	      (* A Response packet will be generated in Step 11 *)
+	 *	 Otherwise,
+	 *	      Generate Reset(No Connection) unless P.type = Reset
+	 *	      Drop packet and return
 	 */
 	if (sk->sk_state = DCCP_LISTEN) {
 		if (dh->dccph_type = DCCP_PKT_REQUEST) {
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index cf8af58..32d03e4 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -718,23 +718,23 @@ int dccp_v4_do_rcv(struct sock *sk, stru
 	/*
 	 *  Step 3: Process LISTEN state
 	 *     If S.state = LISTEN,
-	 *	  If P.type = Request or P contains a valid Init Cookie
-	 *	  	option,
-	 *	     * Must scan the packet's options to check for an Init
-	 *		Cookie.  Only the Init Cookie is processed here,
-	 *		however; other options are processed in Step 8.  This
-	 *		scan need only be performed if the endpoint uses Init
-	 *		Cookies *
-	 *	     * Generate a new socket and switch to that socket *
-	 *	     Set S := new socket for this port pair
-	 *	     S.state = RESPOND
-	 *	     Choose S.ISS (initial seqno) or set from Init Cookie
-	 *	     Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
-	 *	     Continue with S.state = RESPOND
-	 *	     * A Response packet will be generated in Step 11 *
-	 *	  Otherwise,
-	 *	     Generate Reset(No Connection) unless P.type = Reset
-	 *	     Drop packet and return
+	 *	 If P.type = Request or P contains a valid Init Cookie option,
+	 *	      (* Must scan the packet's options to check for Init
+	 *		 Cookies.  Only Init Cookies are processed here,
+	 *		 however; other options are processed in Step 8.  This
+	 *		 scan need only be performed if the endpoint uses Init
+	 *		 Cookies *)
+	 *	      (* Generate a new socket and switch to that socket *)
+	 *	      Set S := new socket for this port pair
+	 *	      S.state = RESPOND
+	 *	      Choose S.ISS (initial seqno) or set from Init Cookies
+	 *	      Initialize S.GAR := S.ISS
+	 *	      Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
+	 *	      Continue with S.state = RESPOND
+	 *	      (* A Response packet will be generated in Step 11 *)
+	 *	 Otherwise,
+	 *	      Generate Reset(No Connection) unless P.type = Reset
+	 *	      Drop packet and return
 	 *
 	 * NOTE: the check for the packet types is done in
 	 *	 dccp_rcv_state_process
@@ -872,13 +872,9 @@ static int dccp_v4_rcv(struct sk_buff *s
 			   skb->nh.iph->saddr, dh->dccph_sport,
 			   skb->nh.iph->daddr, dh->dccph_dport,
 			   inet_iif(skb));
-
-	/* 
+	/*
 	 * Step 2:
-	 * 	If no socket ...
-	 *		Generate Reset(No Connection) unless P.type = Reset
-	 *		Drop packet and return
-	 */
+	 * 	If no socket ...				      */
 	if (sk = NULL) {
 		dccp_pr_debug("failed to look up flow ID in table and "
 			      "get corresponding socket\n");
@@ -927,7 +923,7 @@ no_dccp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 	/*
-	 * Step 2:
+	 * Step 2: If no socket ...
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index c122703..17ddd8b 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -483,10 +483,10 @@ static int dccp_v6_conn_request(struct s
 	/*
 	 * Step 3: Process LISTEN state
 	 *
-	 * Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
+	 *   Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
 	 *
-	 * In fact we defer setting S.GSR, S.SWL, S.SWH to
-	 * dccp_create_openreq_child.
+	 *   In fact we defer setting S.GSR, S.SWL, S.SWH to
+	 *   dccp_create_openreq_child.
 	 */
 	dreq = dccp_rsk(req);
 	dreq->dreq_isr	   = dcb->dccpd_seq;
@@ -756,6 +756,30 @@ static int dccp_v6_do_rcv(struct sock *s
 		return 0;
 	}
 
+	/*
+	 *  Step 3: Process LISTEN state
+	 *     If S.state = LISTEN,
+	 *	 If P.type = Request or P contains a valid Init Cookie option,
+	 *	      (* Must scan the packet's options to check for Init
+	 *		 Cookies.  Only Init Cookies are processed here,
+	 *		 however; other options are processed in Step 8.  This
+	 *		 scan need only be performed if the endpoint uses Init
+	 *		 Cookies *)
+	 *	      (* Generate a new socket and switch to that socket *)
+	 *	      Set S := new socket for this port pair
+	 *	      S.state = RESPOND
+	 *	      Choose S.ISS (initial seqno) or set from Init Cookies
+	 *	      Initialize S.GAR := S.ISS
+	 *	      Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
+	 *	      Continue with S.state = RESPOND
+	 *	      (* A Response packet will be generated in Step 11 *)
+	 *	 Otherwise,
+	 *	      Generate Reset(No Connection) unless P.type = Reset
+	 *	      Drop packet and return
+	 *
+	 * NOTE: the check for the packet types is done in
+	 *	 dccp_rcv_state_process
+	 */
 	if (sk->sk_state = DCCP_LISTEN) {
 		struct sock *nsk = dccp_v6_hnd_req(sk, skb);
 
@@ -822,10 +846,7 @@ static int dccp_v6_rcv(struct sk_buff **
 			    inet6_iif(skb));
 	/*
 	 * Step 2:
-	 * 	If no socket ...
-	 *		Generate Reset(No Connection) unless P.type = Reset
-	 *		Drop packet and return
-	 */
+	 * 	If no socket ...				      */
 	if (sk = NULL) {
 		dccp_pr_debug("failed to look up flow ID in table and "
 			      "get corresponding socket\n");
@@ -870,7 +891,7 @@ no_dccp_socket:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 	/*
-	 * Step 2:
+	 * Step 2: If no socket ...
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 9045438..75fa479 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -97,8 +97,8 @@ struct sock *dccp_create_openreq_child(s
 	/*
 	 * Step 3: Process LISTEN state
 	 *
-	 * // Generate a new socket and switch to that socket
-	 * Set S := new socket for this port pair
+	 *   (* Generate a new socket and switch to that socket *)
+	 *   Set S := new socket for this port pair
 	 */
 	struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);
 
@@ -147,9 +147,9 @@ out_free:
 		/*
 		 * Step 3: Process LISTEN state
 		 *
-		 *	Choose S.ISS (initial seqno) or set from Init Cookie
-		 *	Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init
-		 *	Cookie
+		 *    Choose S.ISS (initial seqno) or set from Init Cookies
+		 *    Initialize S.GAR := S.ISS
+		 *    Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
 		 */
 
 		/* See dccp_v4_conn_request */


