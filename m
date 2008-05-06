From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 May 2008 07:38:01 +0000
Subject: [DCCP/CCID-3] [PATCH 0/4]: Bug fixes and smaller TX socket
Message-Id: <1210059485-691-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A small set of updates, including a bug fix and, by removing redundancies,
reducing the size of the CCID-3/4 socket by a further 18 bytes.  
  
All changes have been uploaded to
	git://eden-feed.erg.abdn.ac.uk/dccp_exp	[dccp,ccid4]
and the `ccid4' subtree has been updated to mirror the changes to CCID-3.	



Patch #1: Removes the ugly history-lookup function tfrc_tx_hist_rtt(), since
          its complex passing of return values triggered ambiguous bug
	  warnings; further subsuming/replacing an earlier test tree patch.
	  The code format is thanks to an earlier suggestion by Arnaldo.

Patch #2: Removes some redundancies (32 lines) in ccid3_hc_tx_parse_options().

Patch #3: Allows ccid_hc_{tx,rx}_parse_options() to check the packet type on
          which options where received, as necessitated by RFC 4340, 10.3.

Patch #4: Finds that the `options_received' sub-struct of ccid3_hc_tx_sock
          is redundant, and removes it altogether. The conversion of received
	  options now happens directly, in ccid3_hc_tx_parse_options().



                  ---------------------------------  
                  ***** Test Tree Update Note *****
                  ---------------------------------
Work on the last patch further helped to fix an omission in an earlier test tree
patch  entitled "[CCID-3]: Remove dead states". The difference below includes:

 * the unnecessary test ("state != NO_FBACK") was removed (the timer
   is first started when changing from NO_SENT => NO_FBACK and from
   then on the state toggles between FBACK and NO_FBACK);

 * the timer is instead disarmed when the socket is no longer in the
   established state: when closing the connection, it is not necessary
   to restart the nofeedback timer -- the connection is in its last
   stages anyway, and the relevant retransmissions of Close or CloseReq
   packets then happen as a matter of course;

 * I think that the following BUG_ON in ccid3_hc_tx_no_feedback_timer(),
	BUG_ON(hctx->p && !hctx->x_calc),
   is now also redundant since, as long as the TX side receives feedback,
   tx_packet_recv is called after tx_parse_options, so that p > 0 leads
   to calling tfrc_calc_x().

--- b/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -213,10 +213,13 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hctx->state));
 
+	/* Ignore and do not restart after leaving the established state */
+	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN))
+		goto out;
+
+	/* Reset feedback state to "no feedback received" */
 	if (hctx->state = TFRC_SSTATE_FBACK)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hctx->state != TFRC_SSTATE_NO_FBACK)
-		goto out;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4


The University of Aberdeen is a charity registered in Scotland, No SC013683.

