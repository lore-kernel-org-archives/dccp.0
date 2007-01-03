From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Jan 2007 21:52:18 +0000
Subject: Re: [PATCH 2/4] DCCP: Add more debugging
Message-Id: <5640c7e00701031352r2855330awe4bea30731319dff@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612281706.25874.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612281706.25874.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hi Ian,
>
> I have tested this at home and found a small error:
>
> |  +    if (hctx->ccid3hctx_x != old_x) {
> |  +            ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
> |  +                           "X_recv=%llu\n", old_x, hctx->ccid3hctx_x,
> |  +                           hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv);
> |               ccid3_update_send_time(hctx);
> => old_x, x, and x_recv are all scaled by 2^6 and need to be divided (would give wrong results).
>
> I have fixed this in the online version (3c_CCID3_add_more_debugging_McDonald.diff);
> the inter-diff between previous and now is (having also updated `x' -> `X' for consistency):
>
Yes I did realise this but I should have been consistent and altered
the label. I thought it might be useful to look at the full number
sometimes....

Anyway I'm happy with your changes.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
