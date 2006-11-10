From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Nov 2006 22:45:50 +0000
Subject: [PATCH 2/3][DCCP]: Update code comments for Step 2/3
Message-Id: <20061110224549.GV23311@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorts out the comments for processing steps 2,3 in section 8.5 of RFC 4340.
All comments have been updated against this document, and the reference to step
2 has been made consistent throughout the files.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 input.c     |   38 +++++++++++++++++---------------------
 ipv4.c      |   38 ++++++++++++++++++--------------------
 ipv6.c      |   33 ++++++++++++++++++++++++++++-----
 minisocks.c |   10 +++++-----
 4 files changed, 68 insertions(+), 51 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 1d24881..97ccdc3 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -431,29 +431,25 @@ int dccp_rcv_state_process(struct sock *
 
 	/*
 	 *  Step 3: Process LISTEN state
-	 *  	(Continuing from dccp_v4_do_rcv and dccp_v6_do_rcv)
 	 *
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
+	 *	      Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init
+	 *	      Cookies Continue with S.state = RESPOND
+	 *	      (* A Response packet will be generated in Step 11 *)
+	 *	 Otherwise,
+	 *	      Generate Reset(No Connection) unless P.type = Reset
+	 *	      Drop packet and return
 	 */
 	if (sk->sk_state = DCCP_LISTEN) {
 		if (dh->dccph_type = DCCP_PKT_REQUEST) {
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d75ce8c..91bffaa 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -729,24 +729,23 @@ int dccp_v4_do_rcv(struct sock *sk, stru
 
 	/*
 	 *  Step 3: Process LISTEN state
-	 *     If S.state = LISTEN,
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
@@ -887,8 +886,6 @@ static int dccp_v4_rcv(struct sk_buff *s
 	/* 
 	 * Step 2:
 	 * 	If no socket ...
-	 *		Generate Reset(No Connection) unless P.type = Reset
-	 *		Drop packet and return
 	 */
 	if (sk = NULL) {
 		dccp_pr_debug("failed to look up flow ID in table and "
@@ -919,6 +916,7 @@ no_dccp_socket:
 		goto discard_it;
 	/*
 	 * Step 2:
+	 * 	If no socket ...
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index c5f28ab..91d22a3 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -487,10 +487,10 @@ static int dccp_v6_conn_request(struct s
 	/*
 	 * Step 3: Process LISTEN state
 	 *
-	 * Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
+	 *   Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
 	 *
-	 * In fact we defer setting S.GSR, S.SWL, S.SWH to
-	 * dccp_create_openreq_child.
+	 *   In fact we defer setting S.GSR, S.SWL, S.SWH to
+	 *   dccp_create_openreq_child.
 	 */
 	dreq = dccp_rsk(req);
 	dreq->dreq_isr	   = dcb->dccpd_seq;
@@ -760,6 +760,30 @@ static int dccp_v6_do_rcv(struct sock *s
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
 
@@ -826,8 +850,6 @@ static int dccp_v6_rcv(struct sk_buff **
 	/*
 	 * Step 2:
 	 * 	If no socket ...
-	 *		Generate Reset(No Connection) unless P.type = Reset
-	 *		Drop packet and return
 	 */
 	if (sk = NULL) {
 		dccp_pr_debug("failed to look up flow ID in table and "
@@ -857,6 +879,7 @@ no_dccp_socket:
 		goto discard_it;
 	/*
 	 * Step 2:
+	 * 	If no socket ...
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 0f228ab..d3de696 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -98,8 +98,8 @@ struct sock *dccp_create_openreq_child(s
 	/*
 	 * Step 3: Process LISTEN state
 	 *
-	 * // Generate a new socket and switch to that socket
-	 * Set S := new socket for this port pair
+	 *   (* Generate a new socket and switch to that socket *)
+	 *   Set S := new socket for this port pair
 	 */
 	struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);
 
@@ -148,9 +148,9 @@ out_free:
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
