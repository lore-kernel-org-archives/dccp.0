From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 04 Jan 2007 23:31:15 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <5640c7e00701041531n4eb6b913s88914a702b5d1050@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/5/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> I am assuming however that the incomplete loss interval is NOT included in the
> 'hcrx->ccid3hcrx_li_hist' list.  If that list DOES include the incomplete loss
> interval, then the code would need to be different.
>
Correct.

> I don't quite get why one needs dccp_li_hist_recalc_recalcloss.  One could do
> probably do that simpler, and maybe Ian can explain his reasoning.  Why is it
> necessary at all?  But RFC3448 does require that one use the incomplete loss
> interval in the i_tot calculations.
>
The reason for this is if you are recalculating i_mean based on non
loss you should check after every packet received. However this
involves quite a lot of calculations on linked lists which are CPU
intensive and also stall other processes potentially with locks being
taken. So what I've done is looked at how many packets of non loss
would be required to alter i_mean. This is then added to the current
sequence number and stored in hist_recalc_recalcloss. I then just do a
simple comparison on every packet to see if we've met this high water
mark.

> One nit.  If you are following RFC terminology i_tot0 should include non_loss,
> but in the code i_tot1 does.  The code seems correct except for the switching
> of i_tot0 and i_tot1.
>
I'll look into that when I get a chance.

Thanks Eddie,

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
