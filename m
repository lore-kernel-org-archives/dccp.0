From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 10 Nov 2007 12:23:20 +0000
Subject: [Announce]: Test Tree and CCID4 Tree updated
Message-Id: <20071110122320.GA12971@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is to announce that the test tree on git://eden-feed.erg.abdn.ac.uk/dccp_exp
has now been updated with regard to removal of spinlocks (changelog as per previous mail).

The CCID4 tree has also been updated to match the changes, changes are below.

----------------------------------------------------------------------------------------
                      CCID 4  Update
----------------------------------------------------------------------------------------
I have patched your second patch [2/25] with regard to the code at the 
bottom of the message and traced those two hunks throughout the patch set. 

The set compiles cleanly (but see other email regarding state names).
I have further `repaired' all the whitespace errors: almost half of the
patches had blanks instead of tabs for indentation. Please check next
time - it is easy to avoid but tedious to get out once it is in.

Can you please check the CCID4 tree out 

	git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp ccid4

and see if you are ok with the state of your patches. Ian has a nice script
to convert a tree into a set of patches, which can be used for this purpose:
	http://wlug.org.nz/KernelDevelopmentWithGit

Note - I have only done compilation tests, it would be good if you run your tests.
Will also do some more CCID4-specific testing when I get a little more time.

Gerrit

---------------> Difference to Patch 2/25 before/after <---------------------

--- a/net/dccp/ccids/ccid4.c
+++ b/net/dccp/ccids/ccid4.c
@@ -781,8 +781,6 @@ static void ccid4_hc_rx_packet_recv(stru
 	u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb);
 
-	spin_lock(&hcrx->ccid4hcrx_hist.lock);
-
 	if (unlikely(hcrx->ccid4hcrx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			do_feedback = FBACK_INITIAL;
@@ -846,8 +844,6 @@ update_records:
 	tfrc_rx_hist_update(&hcrx->ccid4hcrx_hist, skb, ndp);
 
 done_receiving:
-	spin_unlock(&hcrx->ccid4hcrx_hist.lock);
-
 	if (do_feedback)
 		ccid4_hc_rx_send_feedback(sk, skb, do_feedback);
 }
