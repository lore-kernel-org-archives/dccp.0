From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 08 Jan 2007 12:59:20 +0000
Subject: AUDIT: Safe usage of before48/after48 in the DCCP code
Message-Id: <200701081300.15691@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

We were having a bit of discussion on netdev@vger regarding the new definition of before48
which was motivated at the end of the email http://www.mail-archive.com/dccp@vger.kernel.org/msg01153.html

The result of the netdev discussion was that one can not argue that before48/after48 is safer
or less ambiguous to use unless one performs an audit against all occurrences in the code.

Therefore such a due analysis is provided below.


		1) General cases
		========

CASE 1: calls of the form 
	 * if (before48(a,b)) or 
	 * if (after48(b,a))
        are not ambiguous due to the definition of before48 (see above link for details).

CASE 2: calls of the form
	 * if (!before48(a, b)) or
	 * if (!after48(b, a))
        can be ambiguous - it depends on the context if the ambiguity requires further
        resolution. 


		2) Detailed breakdown of before48/after48 usage
		=======================
Here is the complete list of cases where before48/after48 are currently used in the code, 
plus analysis whether the use of the new definition of before48 introduces problems or not.

	
net/dccp/dccp.h-136-static inline u64 max48(const u64 seq1, const u64 seq2)
net/dccp/dccp.h-137-{
net/dccp/dccp.h:138:	return after48(seq1, seq2) ? seq1 : seq2;
net/dccp/dccp.h-139-}
net/dccp/dccp.h-140-
=> CASE 1 - safe.
		

net/dccp/ccids/ccid2.c-586-		/* it's a later packet */
net/dccp/ccids/ccid2.c:587:		else if (after48(seqno, hctx->ccid2hctx_rpseq)) {
net/dccp/ccids/ccid2.c-588-			hctx->ccid2hctx_rpdupack++;
=> CASE 1 - safe.


net/dccp/ccids/ccid2.c-614-	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
net/dccp/ccids/ccid2.c:615:	if (after48(ackno, hctx->ccid2hctx_high_ack))
net/dccp/ccids/ccid2.c-616-		hctx->ccid2hctx_high_ack = ackno;
=> CASE 1 - safe.


net/dccp/ccids/ccid2.c:650:			while (after48(seqp->ccid2s_seq, ackno)) {
net/dccp/ccids/ccid2.c-651-				if (seqp = hctx->ccid2hctx_seqt) {
net/dccp/ccids/ccid2.c-652-					done = 1;
net/dccp/ccids/ccid2.c-653-					break;
=> CASE 1 - safe.


net/dccp/ccids/lib/packet_history.c-225-	if (!list_empty(li_list)) {
net/dccp/ccids/lib/packet_history.c-226-		list_for_each_entry_safe(entry, next, rx_list, dccphrx_node) {
net/dccp/ccids/lib/packet_history.c-227-			if (num_later = 0) {
net/dccp/ccids/lib/packet_history.c:228:				if (after48(nonloss_seqno,
net/dccp/ccids/lib/packet_history.c-229-				   entry->dccphrx_seqno)) {
net/dccp/ccids/lib/packet_history.c-230-					list_del_init(&entry->dccphrx_node);
net/dccp/ccids/lib/packet_history.c-231-					dccp_rx_hist_entry_delete(hist, entry);
=> CASE 1 - safe.


net/dccp/ackvec.c-268-	if (av->dccpav_vec_len = 0) {
net/dccp/ackvec.c-269-		av->dccpav_buf[av->dccpav_buf_head] = state;
net/dccp/ackvec.c-270-		av->dccpav_vec_len = 1;
net/dccp/ackvec.c:271:	} else if (after48(ackno, av->dccpav_buf_ackno)) {
net/dccp/ackvec.c-272-		const u64 delta = dccp_delta_seqno(av->dccpav_buf_ackno,
=> CASE 1 - safe.


net/dccp/ackvec.c-431-            /*
net/dccp/ackvec.c-432-             * If our AVR sequence number is greater than the ack, go
net/dccp/ackvec.c-433-             * forward in the AVR list until it is not so.
net/dccp/ackvec.c-434-             */
net/dccp/ackvec.c-435-		list_for_each_entry_from(avr, &av->dccpav_records,
net/dccp/ackvec.c-436-					 dccpavr_node) {
net/dccp/ackvec.c:437:			if (!after48(avr->dccpavr_ack_seqno, *ackno))
net/dccp/ackvec.c-438-				goto found;
net/dccp/ackvec.c-439-		}
net/dccp/ackvec.c-440-          /* End of the dccpav_records list, not found, exit */
net/dccp/ackvec.c-441-          break;

=> CASE 2: The code jumps to found whenever !before48(*ackno, avr->dccpavr_ack_seqno) or if the two arguments are
            2^47 apart. 
             * with the old definition the case "2^47 apart"  was considered as 'not found';
	     * with the new definition the case "2^47 apart"  is  considered as 'found'.
            However: Please correct me if I am wrong, but I think that the case "2^47 apart" is entirely irrelevant
            here. My argument to support this is that Ack Vectors refer to successive sequence numbers (modulo 
            wraparound, but we are considering this already). The highest possible difference of sequence numbers that
            fit into a single Ack Vector is 16192 (cf. RFC 4340, 11.4) - which is far less than 2^47. 
            Hence this use is safe.

net/dccp/ackvec.c:60:		BUG_ON(before48(avr->dccpavr_ack_seqno,
net/dccp/ackvec.c-61-                           head->dccpavr_ack_seqno));
=> CASE 1 - safe.

net/dccp/minisocks.c:199:		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_isr)) {
net/dccp/minisocks.c-200-			dccp_pr_debug("Retransmitted REQUEST\n");
=> CASE 1 - safe.


net/dccp/ccids/ccid2.c:619:	while (before48(seqp->ccid2s_seq, ackno)) {
net/dccp/ccids/ccid2.c-620-		seqp = seqp->ccid2s_next;
=> CASE 1 - safe.


net/dccp/ccids/ccid2.c-701-	 * Check for NUMDUPACK
net/dccp/ccids/ccid2.c-702-	 */
net/dccp/ccids/ccid2.c-703-	seqp = hctx->ccid2hctx_seqt;
net/dccp/ccids/ccid2.c:704:	while (before48(seqp->ccid2s_seq, hctx->ccid2hctx_high_ack)) {
=> CASE 1 - safe.


net/dccp/input.c-74-      *   Step 5: Prepare sequence numbers for Sync
net/dccp/input.c-75-      *     If P.type = Sync or P.type = SyncAck,
net/dccp/input.c-76-      *        If S.AWL <= P.ackno <= S.AWH and P.seqno >= S.SWL,
net/dccp/input.c-77-      *           / * P is valid, so update sequence number variables
net/dccp/input.c-78-      *               accordingly.  After this update, P will pass the tests
net/dccp/input.c-79-      *               in Step 6.  A SyncAck is generated if necessary in
net/dccp/input.c-80-      *               Step 15 * /
net/dccp/input.c-81-      *           Update S.GSR, S.SWL, S.SWH
net/dccp/input.c-82-      *        Otherwise,
net/dccp/input.c-83-      *           Drop packet and return
net/dccp/input.c-84-      */
net/dccp/input.c-85-     if (dh->dccph_type = DCCP_PKT_SYNC ||
net/dccp/input.c-86-         dh->dccph_type = DCCP_PKT_SYNCACK) {
net/dccp/input.c-87-            if (between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
net/dccp/input.c-88-                           dp->dccps_awl, dp->dccps_awh) &&
net/dccp/input.c:89:		    !before48(DCCP_SKB_CB(skb)->dccpd_seq, dp->dccps_swl))
net/dccp/input.c-90-			dccp_update_gsr(sk, DCCP_SKB_CB(skb)->dccpd_seq);

=> CASE 2: Here swl corresponds to SWL as defined in RFC 4340, 7.5.1. 
             * with the old definition, gsr was not updated when P.seqno and S.SWL are 2^47 apart;
             * with the new definition, gsr is      updated when P.seqno and S.SWL are 2^47 apart.
          
=> TODO:  To handle this case correctly, we need to reconsider the intention: "P.seqno >= S.SWL". 
           This can without problem be captured by the dccp_delta_seqno(a, b) function, which returns 
           a value >= 0 when a=b or a is `before' b in the new definition. Hence, I'd suggest to replace 
                   !before48(DCCP_SKB_CB(skb)->dccpd_seq, dp->dccps_swl)                 with
                    dccp_delta_seqno(dp->dccps_swl, DCCP_SKB_CB(skb)->dccpd_seq) >= 0



net/dccp/input.c-187-    case DCCP_PKT_REQUEST:
net/dccp/input.c-188-            /* Step 7
net/dccp/input.c-189-             *   or (S.is_server and P.type = Response)
net/dccp/input.c-190-             *   or (S.is_client and P.type = Request)
net/dccp/input.c-191-             *   or (S.state >= OPEN and P.type = Request
net/dccp/input.c-192-             *      and P.seqno >= S.OSR)
net/dccp/input.c-193-             *    or (S.state >= OPEN and P.type = Response
net/dccp/input.c-194-             *      and P.seqno >= S.OSR)
net/dccp/input.c-195-             *    or (S.state = RESPOND and P.type = Data),
net/dccp/input.c-196-             *  Send Sync packet acknowledging P.seqno
net/dccp/input.c-197-             *  Drop packet and return
net/dccp/input.c-198-             */
net/dccp/input.c-199-            if (dp->dccps_role != DCCP_ROLE_LISTEN)
net/dccp/input.c-200-                    goto send_sync;
net/dccp/input.c-201-            goto check_seq;
net/dccp/input.c-202-    case DCCP_PKT_RESPONSE:
net/dccp/input.c-203-            if (dp->dccps_role != DCCP_ROLE_CLIENT)
net/dccp/input.c-204-                    goto send_sync;
net/dccp/input.c-205-check_seq:
net/dccp/input.c:206:		if (!before48(DCCP_SKB_CB(skb)->dccpd_seq, dp->dccps_osr)) {
net/dccp/input.c-207-send_sync:
net/dccp/input.c-208-			dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq,
net/dccp/input.c-209-				       DCCP_PKT_SYNC);

=> CASE 2: Here we have the same case in principle as above. A sync shall be sent if the condition
            "P.seqno >= S.OSR" is true. 
	      * with the old definition, a sync is not sent if P.seqno and S.OSR are 2^47 apart; 
              * with the new definition, a sync is     sent if P.seqno and S.OSR are 2^47 apart.
            Nothing harmful happens, the packet is dropped eventually anyway. It seems that whether
            using the old or new definition here is debatable; to make it consistent with the above case;
            one could consider replacing
                 !before48(DCCP_SKB_CB(skb)->dccpd_seq, dp->dccps_osr)                    with
                 dccp_delta_seqno(dp->dccps_osr, DCCP_SKB_CB(skb)->dccpd_seq) >=  0
            if desired.



		3) Conclusion
		======There are only two cases which need special consideration, all other uses of before48/after48 in the DCCP
code are unproblematic. I shall provide a patch to update the two cases.
