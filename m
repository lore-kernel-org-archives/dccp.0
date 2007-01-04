From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 04 Jan 2007 23:45:45 +0000
Subject: Re: [dccp] Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <459D91A9.3070108@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> The reason for this is if you are recalculating i_mean based on non
> loss you should check after every packet received. However this
> involves quite a lot of calculations on linked lists which are CPU
> intensive and also stall other processes potentially with locks being
> taken. So what I've done is looked at how many packets of non loss
> would be required to alter i_mean. This is then added to the current
> sequence number and stored in hist_recalc_recalcloss. I then just do a
> simple comparison on every packet to see if we've met this high water
> mark.

I guess there's a minor 4-byte space tradeoff here, but it would seem simpler 
just to store i_tot0 and i_tot1 as variables in the ccid3 structure.  Then on 
every consecutive non-lost packet you simply increment i_tot1 by 4 and 
recalculate i_mean.

Eddie
