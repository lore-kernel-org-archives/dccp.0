From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 05 Jan 2007 00:24:24 +0000
Subject: Re: [dccp] Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <5640c7e00701041624g9a6c914jfdcaf0f1d01ceb61@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/5/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> You shouldn't need to iterate through the list, since i_mean is just
> i_tot/w_tot, and w_tot is a constant.  You do need to divide, though.
>
> If it makes no difference to you I'd recommend going with the simpler version
> -- the logic in dccp_li_hist_recalc_recalcloss is difficult to follow; I
> wouldn't want to be on the hook for its correctness ;)
>

I'll have a look at it later on, but don't have much free time at
present due to family responsibilities. I've done quite a lot of
testing and believe to be correct, and have included a lot of the
thinking in the comments. The thing is that it doesn't actually
calculate i_mean itself so that same base calculation is used.

> Also, the weights in dccp_li_hist_w appear to be wrong.  They should be 5, 5,
> 5, 5, 4, 3, 2, 1, not 4,4,4,4,3,2,1,1, according to rfc3448.
>
I don't believe so. We've done this as per section 8 of RFC3448 and
divide by 4 rather than 5.

-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
