From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 08 Jan 2007 16:32:39 +0000
Subject: Re: [SUMMARY]: Problems with loss interval recalculation / audit against [RFC 3448, 5.4]
Message-Id: <200701081632.40044@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701051829.20415@strip-the-willow>
In-Reply-To: <200701051829.20415@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thank you for your feedback.

|  Gerrit, this summary is not right.
I am just a human being and so it can happen that I am not right. 
To keep this constructive, please let's examine the facts, ok?

There are some good points you are making, but even using these the problem is not
fully solved, there are further problems which also need to be tackled and which did
not before appear in the analysis.

|  RFC 3448 says that I_0 "represents the number of packets received since the 
|  last loss event".  (Section 5.5)  In the Linux implementation, this number is 
|  NOT stored in the li_entry list.  It must be calculated.  This is what Ian's 
|  nonloss manipulations do.
|  
|  There are a number of errors in your discussion.  You claim that I_0 is the 
|  "most recent loss interval", and that it is stored in the li_entry structures. 
|    But what RFC 3448 means by I_0 is not stored in the Linux DCCP 
|  implementation's li_entry structures.  Your comments under "This is the 
|  crucial point" do not seem to realize this.
There is truth in this, but I need to put it in relation to how the list is handled. 
What I stated below in "This is the crucial point" is that the highest received seqno
and CCVal are always stored at the head of the list. 

( I just found out that there is another
  PROBLEM#1: For the first loss interval (as per [RFC 3448, 6.3.1]), the timestamp
            and sequence number are not stored, only the interval is. )

For all other loss events, timestamp and sequence number are stored. This also holds
for I_0; it could be that the interval is 0 here due to (seq_temp becomes `interval')
   seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_nonloss);
but I am not entirely sure about that. And it is probably safer to encode this
case more explicitly.

In any way, this clarification leads to 
PROBLEM#2: Since I_0 always sits at the head of the list, there are at most n=7 
           completed loss interval entries (not 8 as the RFC recommends).
  
|  Your comments about Ian's patch are also wrong, for the same reason.  I 
|  believe Ian's patch calculates I_tot0 and I_tot1 correctly, although with 
|  swapped names.  Certainly if there is a problem it is not the one you have 
|  identified.
If the above assumption that the interval of I_0 is 0 holds then in Ian's patch
(where I_0' is the interval called `non_loss' in Ian's patch) we have that
 -  I_tot0 is the sum  I_1 * w_1 + ... I_7 * w_7  
 -  I_tot1 is the sum  I_0' * w_0 + I_1 * w_2 +  I_2 * w3 + ... + I_6 * w_7
This can't be right.

  
|  As a side note, you say: "if k < 7 then I_tot0 and I_tot1 always contain _all_ 
|  intervals, from 0..k, - which is again not conform with the specification". 
|  What do you think the specification demands here?  I think the specification 
|  DOES want I_tot0 and I_tot1 to contain all intervals when there are fewer than 8.
|  
|  So your conclusion is wrong as well.  Ian's patch is a strict improvement on 
|  the existing code.  I don't see how it worsens compliance.
As said, I agree with you that there are points in the analysis which need revision.
However, as there are problems with Ian's patch such as the one stated above, 
and as there are yet unresolved problems with the current code, we need to work a little
harder to really resolve the problems - and without introducing new bugs.

  
|  It would be useful to migrate to an array-based implementation but not a panacea.
|  
|  Again, Ian's patch seems good to apply.
Disagree due to the reasons above.

Again thanks for your input, such discussion helps clarifying where the real issues are.
I will try to compile an update of the problems discussed so far, further comments are welcome.

Gerrit

|  Gerrit Renker wrote:
|  > This summarizes the issues that have been discussed, 
|  >      reviews Ian's patch, and
|  >      tries to identify related problems which impede progress.
|  > 
|  > 
|  > 1) List of known bugs affecting this problem
|  > ======================
|  > 
|  > The following problems are still unresolved:
|  > 
|  > BUG#1: No attempt is made to ensure that losses are within the same RTT. This code is 
|  >        missing. Ian has pointed this out already in December and I think he is working
|  >        on it (patch `fix_consecutive_loss.diff'). Now we have another problem:
|  > 
|  > BUG#2: RTT estimation from CCVal does currently not work. There is code which goes towards
|  >        this, but only for the first loss interval (function ccid3_hc_rx_calc_first_li, lines
|  >        793 ... 835). Currently the code uses timestamps everywhere, hence we are not conforming
|  >        to [RFC 4342, sec. 10.3]. This impedes fixing BUG#1; I have been working on this but not
|  >        completed testing yet.
|  > 
|  > BUG#3: ccid3_hc_rx_detect_loss does not update hcrx->ccid3hcrx_ccval_nonloss in sync with
|  >        hcrx->ccid3hcrx_seqno_nonloss  => this makes it difficult to fix BUG#1, since as a conseqence
|  >        we now longer know which non-loss CCVal belongs to which non-loss sequence number.
|  > 
|  > BUG#4: Weights are scaled by 4 but the end result, in dccp_li_hist_calc_i_mean, is not divided by 4.
|  >        This is fixed in Ian's patch, but _not_ in the existing code.> 
|  > WISH#1: Using an array for the loss history would much simplify the code (as per earlier emails).
|  > 
|  > 
|  > 2) Issues raised by Eddie
|  > ============|  > The following are quotes from earlier emails.
|  > 
|  > (a) "From Ian's patch, it appears that the OLD code DID NOT include the most 
|  >      recent loss interval (i.e., the incomplete loss interval, the one that has no 
|  >      losses) in its calculation of i_tot1.  Ian has added the following line to do 
|  >      this:
|  > 
|  >      > +    i_tot1 += non_loss * dccp_li_hist_w[0];
|  > 
|  >      This is correct.  The RFC requires that one of the i_tots include the 
|  >      incomplete loss interval.  So this part of the patch is required for RFC 
|  >      compliance.
|  > 
|  >      I am assuming however that the incomplete loss interval is NOT included in the 
|  >      'hcrx->ccid3hcrx_li_hist' list.  If that list DOES include the incomplete loss 
|  >      interval, then the code would need to be different."
|  > 
|  >    => This is the crucial point: the last loss interval is always added to the list first;
|  >        both before and in Ian's patch. To illustrate, the calling path for this is as follows.
|  > 
|  > 	ccid3_hc_rx_packet_recv():
|  > 		loss = ccid3_hc_rx_detect_loss(sk, packet);
|  > 
|  >         ccid3_hc_rx_detect_loss():
|  > 		while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno) > TFRC_RECV_NUM_LATE_LOSS) {
|  > 			loss = 1;
|  > 			ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
|  > 		 	       	        	  hcrx->ccid3hcrx_ccval_nonloss);
|  > 
|  > 	ccid3_hc_rx_update_li(): adds interval to hcrx->ccid3hcrx_li_hist
|  > 
|  >         Back in ccid3_hc_rx_packet_recv(), dccp_li_hist_calc_i_mean() is only executed when loss = 1,
|  >         hence in dccp_li_hist_calc_i_mean() the most recent interval I_0 is always at the top of the list.
|  > 
|  > 
|  > (b) "i_tot0 should include non_loss, but in the code i_tot1 does."
|  >     => Please see below.
|  > 
|  > (c) "Also, the weights in dccp_li_hist_w appear to be wrong.  They should be 5, 5, 5, 5, 4, 3, 2, 1"
|  >     => Please see BUG#4. To me it seems better to use exact values, but the implication behind these
|  >         powers of 2 is that the implicitly get converted into bit-shifts and hence execute faster (as
|  >         Arnaldo taught me).
|  > 
|  > 		
|  > 3) Auditing against RFC 3448 (draft 3448bis)
|  > ======================
|  > I am referring to the more recent draft 3448bis, section 5.4, since the description in that draft is better
|  > with regard to the case where k < 8 loss intervals have been found.
|  > 
|  > The following preconditions and terminology apply:
|  > 
|  > 	* n is set to 7 and indices run 0..7, hence this is in accordance with [RFC 3448, 5.4]: we are
|  >           never using more than 8 loss intervals, as is suggested there.
|  > 
|  > 	* I_0 is the most recent loss interval. It is always included (see above for explanation).
|  > 
|  > 	* The loss interval list is managed in LIFO manner (list_add), hence I_0 is at the head, and
|  >           I_7 is at the tail.
|  > 
|  > 	* Due to static allocation in dccp_li_hist_interval_new() and due to the add/delete cycle in 
|  >           ccid3_hc_rx_update_li, the list always contains a constant number of 8 elements.
|  > 
|  > 
|  > (a) Checking the way I_tot0 and W_tot are added
|  > -----------------------------------------------    
|  > The specification states the following (irrelevant statements have been removed):
|  > 	I_tot0 = 0;
|  > 	W_tot = 0;
|  >         for (i = 0 to k-1) {
|  >            I_tot0 = I_tot0 + (I_i * w_i);
|  >            W_tot  = W_tot  + w_i;
|  >          }
|  > 	
|  > 	=> In the current code we have 
|  > 
|  > 	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
|  > 		if (li_entry->dccplih_interval != ~0) {
|  > 			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
|  > 			w_tot  += dccp_li_hist_w[i];
|  > 			
|  > 	=> In the current code, w_tot is added correctly, but i_tot0 is not, since I_tot7 will
|  >             currentlly be added. Or, if k < 7, I_tot_k will be added (and it should not be).
|  >             This is _not_ fixed by Ian's patch.
|  > 
|  > 			
|  > (b) Checking the way I_tot1 is summed
|  > -------------------------------------
|  > Here the specification states the following (again only relevant parts printed):
|  > 
|  >          I_tot1 = 0;
|  >          for (i = 1 to k) {
|  >            I_tot1 = I_tot1 + (I_i * w_(i-1));
|  >          }
|  > 
|  > 	 => In the current code we have:
|  > 	
|  > 	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
|  > 		if (li_entry->dccplih_interval != ~0) {
|  > 			if (i != 0)
|  > 				i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i - 1];
|  > 
|  > 	 => This is correct, since it sums up all I_i's from 1..k as required
|  > 
|  > 	 => By contrast, Ian's patch does the following.
|  > 	
|  > 	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
|  >  		if (li_entry->dccplih_interval != ~0U) {
|  > 			/* ... */
|  > 			if (i != 7)
|  > 				i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i + 1];
|  > 			if (i = 0) {
|  > 				non_loss = dccp_hdr_seq(skb);
|  > 				sub48(&non_loss, li_entry->dccplih_seqno);
|  > 			}
|  > 		}
|  > 		if (++i > DCCP_LI_HIST_IVAL_F_LENGTH)
|  >  			break;
|  >  	}
|  > 	/* ... */
|  > 	i_tot1 += non_loss * dccp_li_hist_w[0];
|  > 
|  > 	=> This stores the value of the first interval in the list into `non_loss' after recomputing it 
|  >             (which is not necessary, since the first interval is always at the head of the list).
|  >             Furthermore, transcribed into pseudo code, the loop does the following:
|  > 
|  > 	    I_tot1 = 0;
|  > 	    for (i = 0 to k) {           		/* k is less than or equal to 8 */
|  > 		if (i != 7 )
|  >                    I_tot1 = I_tot1 + (I_i * w_(i+1));
|  >             }
|  >             
|  >             This is not conform with [RFC 3448, 5.4], even if i_tot0 and i_tot1 are switched. 
|  > 
|  >            The other problem with this code is that if k < 7 then I_tot0 and I_tot1 always contain _all_ 
|  >            intervals, from 0..k, - which is again not conform with the specification.
|  > 
|  > 4) Conclusion
|  > ======|  > The current code does not in all cases conform with [RFC 3448, 5.4], Ian's patch changes parts which currently
|  > conform to non-conform ones and fixes one existing bug (BUG#4). On the whole, neither is a satisfactory solution.
|  > 
|  > 5) Suggested fix
|  > ========
|  > I think we should migrate to an array-based implementation and fix the issues flagged up above there. In particular,
|  >  * the statement 
|  > 	if (++i > DCCP_LI_HIST_IVAL_F_LENGTH)
|  >  			break;
|  >    is currently redundant: due to static allocation, we never have more than DCCP_LI_HIST_IVAL_F_LENGTH elements
|  > 
|  >  * we have to resort to the clumsy comparison against ~0U to identify empty loss intervals. With a ring-buffer-like        
|  >    array solution, we could keep track of the current fill level of the list
|  > 
|  >  * if k < 8 we have no way of knowing this before the loop, hence the problem with updating I_tot0 will persist
|  >    as long as we don't record the `fill level' of the buffer
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
