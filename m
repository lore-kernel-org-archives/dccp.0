From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 01 Mar 2011 05:59:45 +0000
Subject: Re: dccp: null-pointer dereference on close
Message-Id: <20110301055945.GA4761@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
List-Id: <dccp.vger.kernel.org>
References: <20110226174505.GB3609@localhost>
In-Reply-To: <20110226174505.GB3609@localhost>
To: dccp@vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Johan,

thanks a lot for the detailed description.

I think I have found the cause of the dccp timewait problem: in the 
mainline tree there is a path

 dccp_v4_do_rcv() 
	|
	| state other than OPEN
	v
 dccp_rcv_state_process()
	|
	| DCCP_PKT_RESET
	v
 dccp_rcv_reset()
	|
	v
 dccp_time_wait()

In the backtrace dccp_close() had been called, hence dccp_set_state() has
destroyed inet_csk(sk)->icsk_bind_hash, which then subsequently in the
misplaced dccp_time_wait() caused the NULL pointer exception.

I have just checked, this problem seems to not be possible in the test
tree, since it checks first in dccp_rcv_state_process() if DCCP_CLOSED
has been entered (if it receives a packet in this state, it sends a 
Reset with code 3, "No Connection").

I am attaching the relevant patch from the test tree - would it be possible
for you to test it with the same setup? (The relevant passage is right in 
the first hunk, where it tests for state == DCCP_CLOSED).

Will submit this patch subsequently also.

Thanks again,
Gerrit


| root@overo:~# [84140.128631] ------------[ cut here ]------------
| [84140.133575] WARNING: at net/ipv4/inet_timewait_sock.c:141 __inet_twsk_hashdance+0x48/0x128()
| [84140.142517] Modules linked in: arc4 ecb carl9170 rt2870sta(C) mac80211 r8712u(C) crc_ccitt ah
| [84140.151794] [<c0038850>] (unwind_backtrace+0x0/0xec) from [<c0055364>] (warn_slowpath_common)
| [84140.161743] [<c0055364>] (warn_slowpath_common+0x4c/0x64) from [<c0055398>] (warn_slowpath_n)
| [84140.171966] [<c0055398>] (warn_slowpath_null+0x1c/0x24) from [<c02b72d0>] (__inet_twsk_hashd)
| [84140.182373] [<c02b72d0>] (__inet_twsk_hashdance+0x48/0x128) from [<c031caa0>] (dccp_time_wai)
| [84140.192413] [<c031caa0>] (dccp_time_wait+0x40/0xc8) from [<c031c15c>] (dccp_rcv_state_proces)
| [84140.202636] [<c031c15c>] (dccp_rcv_state_process+0x120/0x538) from [<c032609c>] (dccp_v4_do_)
| [84140.213043] [<c032609c>] (dccp_v4_do_rcv+0x11c/0x14c) from [<c0286594>] (release_sock+0xac/0)
| [84140.222442] [<c0286594>] (release_sock+0xac/0x110) from [<c031fd34>] (dccp_close+0x28c/0x380)
| [84140.231475] [<c031fd34>] (dccp_close+0x28c/0x380) from [<c02d9a78>] (inet_release+0x64/0x70)
| [84140.240386] [<c02d9a78>] (inet_release+0x64/0x70) from [<c0284ddc>] (sock_release+0x24/0xb8)
| [84140.249328] [<c0284ddc>] (sock_release+0x24/0xb8) from [<c0284e94>] (sock_close+0x24/0x34)
| [84140.258087] [<c0284e94>] (sock_close+0x24/0x34) from [<c00c2e4c>] (fput+0x108/0x1f4)
| [84140.266296] [<c00c2e4c>] (fput+0x108/0x1f4) from [<c00c0104>] (filp_close+0x70/0x7c)
| [84140.274505] [<c00c0104>] (filp_close+0x70/0x7c) from [<c00c01c4>] (sys_close+0xb4/0x10c)
| [84140.283081] [<c00c01c4>] (sys_close+0xb4/0x10c) from [<c0033a80>] (ret_fast_syscall+0x0/0x30)
| [84140.292114] ---[ end trace b8877ec9d542c32e ]---
| [84140.296997] Unable to handle kernel NULL pointer dereference at virtual address 00000010


--82I3+IH0IqGh5yIs
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="DCCP_Reorder-Input-Processing.diff"

dccp: Clean up slow-path input processing

This patch rearranges the order of statements of the slow-path input processing
(i.e. any other state than OPEN), to resolve the following issues.

 1. Dependencies: the order of statements now better matches RFC 4340, 8.5, i.e.
    step 7 is before step 9 (previously 9 was before 7), and parsing options in
    step 8 (which can consume resources) now comes after step 7.
 2. Bug-fix: in state CLOSED, there should not be any sequence number checking
    or option processing. This is why the test for CLOSED has been moved after
    the test for LISTEN.
 3. As before sequence number checks are omitted if in state LISTEN/REQUEST, due
    to the note underneath the table in RFC 4340, 7.5.3.
 4. Packets are now passed on to Ack Vector / CCID processing only after
    - step 7  (receive unexpected packets), 
    - step 9  (receive Reset),
    - step 13 (receive CloseReq),
    - step 14 (receive Close)
    and only if the state is PARTOPEN. This simplifies CCID processing:
    - in LISTEN/CLOSED the CCIDs are non-existent;
    - in RESPOND/REQUEST the CCIDs have not yet been negotiated;
    - in CLOSEREQ and active-CLOSING the node has already closed this socket;
    - in passive-CLOSING the client is waiting for its Reset.
    In the last case, RFC 4340, 8.3 leaves it open to ignore further incoming
    data, which is the approach taken here.

As a result of (3), CCID processing is now indeed confined to OPEN/PARTOPEN
states, i.e. congestion control is performed only on the flow of data packets. 

This avoids pathological cases of doing congestion control on those messages
which set up and terminate the connection. 

I have done some checks to see if this creates a problem in other parts of
the code. This seems not to be the case; even if there were one, it would be
better to fix it than to perform congestion control on Close/Request/Response
messages. Similarly for Ack Vectors (as they depend on the negotiated CCID).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   68 ++++++++++++++++++++++++++-----------------------------
 1 file changed, 33 insertions(+), 35 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -614,22 +614,36 @@ int dccp_rcv_state_process(struct sock *
 		/* Caller (dccp_v4_do_rcv) will send Reset */
 		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
 		return 1;
+	} else if (sk->sk_state == DCCP_CLOSED) {
+		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
+		return 1;
 	}
 
-	if (sk->sk_state != DCCP_REQUESTING && sk->sk_state != DCCP_RESPOND) {
-		if (dccp_check_seqno(sk, skb))
-			goto discard;
-
-		/*
-		 * Step 8: Process options and mark acknowledgeable
-		 */
-		if (dccp_parse_options(sk, NULL, skb))
-			return 1;
+	/* Step 6: Check sequence numbers (omitted in LISTEN/REQUEST state) */
+	if (sk->sk_state != DCCP_REQUESTING && dccp_check_seqno(sk, skb))
+		goto discard;
 
-		dccp_handle_ackvec_processing(sk, skb);
-		dccp_deliver_input_to_ccids(sk, skb);
+	/*
+	 *   Step 7: Check for unexpected packet types
+	 *      If (S.is_server and P.type == Response)
+	 *	    or (S.is_client and P.type == Request)
+	 *	    or (S.state == RESPOND and P.type == Data),
+	 *	  Send Sync packet acknowledging P.seqno
+	 *	  Drop packet and return
+	 */
+	if ((dp->dccps_role != DCCP_ROLE_CLIENT &&
+	     dh->dccph_type == DCCP_PKT_RESPONSE) ||
+	    (dp->dccps_role == DCCP_ROLE_CLIENT &&
+	     dh->dccph_type == DCCP_PKT_REQUEST) ||
+	    (sk->sk_state == DCCP_RESPOND && dh->dccph_type == DCCP_PKT_DATA)) {
+		dccp_send_sync(sk, dcb->dccpd_seq, DCCP_PKT_SYNC);
+		goto discard;
 	}
 
+	/*  Step 8: Process options */
+	if (dccp_parse_options(sk, NULL, skb))
+		return 1;
+
 	/*
 	 *  Step 9: Process Reset
 	 *	If P.type == Reset,
@@ -637,41 +651,21 @@ int dccp_rcv_state_process(struct sock *
 	 *		S.state := TIMEWAIT
 	 *		Set TIMEWAIT timer
 	 *		Drop packet and return
-	*/
+	 */
 	if (dh->dccph_type == DCCP_PKT_RESET) {
 		dccp_rcv_reset(sk, skb);
 		return 0;
-		/*
-		 *   Step 7: Check for unexpected packet types
-		 *      If (S.is_server and P.type == Response)
-		 *	    or (S.is_client and P.type == Request)
-		 *	    or (S.state == RESPOND and P.type == Data),
-		 *	  Send Sync packet acknowledging P.seqno
-		 *	  Drop packet and return
-		 */
-	} else if ((dp->dccps_role != DCCP_ROLE_CLIENT &&
-		    dh->dccph_type == DCCP_PKT_RESPONSE) ||
-		    (dp->dccps_role == DCCP_ROLE_CLIENT &&
-		     dh->dccph_type == DCCP_PKT_REQUEST) ||
-		    (sk->sk_state == DCCP_RESPOND &&
-		     dh->dccph_type == DCCP_PKT_DATA)) {
-		dccp_send_sync(sk, dcb->dccpd_seq, DCCP_PKT_SYNC);
-		goto discard;
-	} else if (dh->dccph_type == DCCP_PKT_CLOSEREQ) {
+	} else if (dh->dccph_type == DCCP_PKT_CLOSEREQ) {	/* Step 13 */
 		if (dccp_rcv_closereq(sk, skb))
 			return 0;
 		goto discard;
-	} else if (dh->dccph_type == DCCP_PKT_CLOSE) {
+	} else if (dh->dccph_type == DCCP_PKT_CLOSE) {		/* Step 14 */
 		if (dccp_rcv_close(sk, skb))
 			return 0;
 		goto discard;
 	}
 
 	switch (sk->sk_state) {
-	case DCCP_CLOSED:
-		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
-		return 1;
-
 	case DCCP_REQUESTING:
 		queued = dccp_rcv_request_sent_state_process(sk, skb, dh, len);
 		if (queued >= 0)
@@ -680,8 +674,12 @@ int dccp_rcv_state_process(struct sock *
 		__kfree_skb(skb);
 		return 0;
 
-	case DCCP_RESPOND:
 	case DCCP_PARTOPEN:
+		/* Step 8: if using Ack Vectors, mark packet acknowledgeable */
+		dccp_handle_ackvec_processing(sk, skb);
+		dccp_deliver_input_to_ccids(sk, skb);
+		/* fall through */
+	case DCCP_RESPOND:
 		queued = dccp_rcv_respond_partopen_state_process(sk, skb,
 								 dh, len);
 		break;

--82I3+IH0IqGh5yIs--
