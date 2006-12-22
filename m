From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Dec 2006 21:41:54 +0000
Subject: Re: [PATCH 1/1] DCCP: Reorganise loss interval code
Message-Id: <5640c7e00612221341r5750069ey35471ab9a573d12d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612220924.34663.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612220924.34663.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  Applies on top of my previous patches. (So I have to convince Gerrit of the
> |  merits of them first!)
> I tried to apply it but it bombed out with 3 hunks failing. I like the basic idea
> and have another suggestion:

I've recreated it before my other patches so that it will apply. I'll
have to regenerate my other patches too but I'll send this one in a
few minutes. The others will dribble through probably over next little
while (xmas and all that).

>  =>  dccp_li_update_li() is only called in ccid3_hc_rx_detect_loss() and there
>       it is called with the arguments
>       ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
>                                 hcrx->ccid3hcrx_ccval_nonloss)
>
>  => Since hcrx derives from sk via pointer-cast, and since the last two arguments
>      are fields of hcrx, we could simplify the interface to
>      ccid3_hc_rx_update_li(sk)
>
Put this in new patch. Thanks for that.

>  => However, I am not sure that the way  ccid3_hc_rx_update_li() is called is as
>      intentioned.
>
Not sure what you mean here. Can you explain?

> But for the basic idea,
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
>
Thanks.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
