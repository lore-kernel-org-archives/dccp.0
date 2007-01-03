From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Jan 2007 22:22:53 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <5640c7e00701031422y55c205eeif97fbe9a47b68822@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

Comments inline

On 1/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>  1) see previous posting - I think we are still having a misunderstanding here and
>     I do think that what you cite above is already covered by the condition
>     I_tot = max(I_tot0, I_tot1)". That would mean, as soon as we implement [RFC 3448, 5.4],
>     we have this sorted out (and this method has been tested for 7 years).
>

I agree we have a misunderstanding here with each other. I would like
to see the comments from Eddie and others. We both think we're right!!
I'm not prepared to move yet on my position but could still be
persuaded.

Probably the easiest way to illustrate this is:
- Fixed 128 kbits second link.
- Loss occurs when we are only up to 32 kbits per second
- No loss then occurs again or for a very long time
- How do we then use the full bandwidth?

This is what I think the RFC is saying.

> |  The implementation in the kernel, which was wrong logic, also had
> |  wrong implementation! The code was taken over from FreeBSD (relicensed
> |  under GPL) and we actually didn't analyse properly and were excluding
> |  the wrong item from the loop as linked lists ran the opposite
> |  direction in FreeBSD to Linux in this case!!
>  2) if you think this has not been implemented correctly, then can you please point out
>     > where <. The situation at the moment is: you are saying "X has been implemented
>     wrongly, so I use Y to solve the problem". Y however has not much in common with X, so
>     we are left with a broken method X and a non-standard method Y.
>
That is this part of the patch:

u32 dccp_li_hist_calc_i_mean(struct ccid3_hc_rx_sock *hcrx, struct sk_buff *skb)
 {

 	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
 		if (li_entry->dccplih_interval != ~0U) {
 			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
 			w_tot  += dccp_li_hist_w[i];
-			if (i != 0)
-				i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i - 1];
-		}
-
+			if (i != 7)
+				i_tot1 += li_entry->dccplih_interval
+				   * dccp_li_hist_w[i + 1];
+

If you want me to split that into a separate patch I'm fine with that
as I think you can see that is quite separate from the rest.


>  3) I have a suggestion: you seem to be sure of the merits of this solution and report on
>     test results. My suggestion would be to offer using this method via a configuration
>     option (same as per the nofeedback timer threshold). You could put detailed advice into
>     the kernel configuration menu, and we would have the best of both worlds - a standards-
>     compliant TFRC implementation and a configurable Ian's nifty solution. Would that settle
>     things?
>
I'll wait to see the feedback from others first before heading down
that path. Maybe I can even convince you yet! But if we can't resolve
that would be good.

>
> |  All this is is a method of not having to call calc_i_mean for EVERY
> |  packet which would be very expensive on CPU. It is new but is a very
>  4) This code is only invoked when ccid3_hc_rx_detect_loss() returns true, hence it is not
>     invoked for every packet.
>

What I'm referring to here is this part of the patch:
@@ -955,6 +958,15 @@ static void ccid3_hc_rx_packet_recv(struct sock
*sk, struct sk_buff *skb)
 		if (loss)
 			break;

+		if (hcrx->ccid3hcrx_seq_recalc_loss &&
+		 after48(dccp_hdr_seq(skb), hcrx->ccid3hcrx_seq_recalc_loss)) {

If we didn't calculate ccid3hcrx_seq_recalc_loss I would have to run
the code to detect whether we had a long non-loss interval EVERY time
we receive a packet which would use lots of CPU cycles.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
