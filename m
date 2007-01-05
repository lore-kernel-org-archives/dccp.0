From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 05 Jan 2007 00:10:23 +0000
Subject: Re: [dccp] Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <459D976F.2010903@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

You shouldn't need to iterate through the list, since i_mean is just 
i_tot/w_tot, and w_tot is a constant.  You do need to divide, though.

If it makes no difference to you I'd recommend going with the simpler version 
-- the logic in dccp_li_hist_recalc_recalcloss is difficult to follow; I 
wouldn't want to be on the hook for its correctness ;)

Also, the weights in dccp_li_hist_w appear to be wrong.  They should be 5, 5, 
5, 5, 4, 3, 2, 1, not 4,4,4,4,3,2,1,1, according to rfc3448.

Eddie


Ian McDonald wrote:
> Don't you still need to iterate through each element of the list then
> and also do some divisions? This becomes expensive quickly if done for
> every packet. With my code for example if you are running at 1% loss
> then you will only recalculate roughly every 100 packets and only then
> if you haven't had a loss.
> 
> I would like to change the loss interval linked list to a fixed size 8
> element array as we're not changing the size of the linked list at any
> time so it is very inefficient (probably a text book case of when not
> to use a linked list!!)
> 
> Ian
