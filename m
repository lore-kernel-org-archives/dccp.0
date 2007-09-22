From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 22 Sep 2007 20:33:54 +0000
Subject: Re: [PATCH 3/5] CCID 4: Enforce a minimum sending rate of 10 ms
Message-Id: <5640c7e00709221333m73ad575elcaf8c82481e2e3a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920112443.GB26233@kikai.katei.fi>
In-Reply-To: <20070920112443.GB26233@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/20/07, Tommi Saviranta <wnd@iki.fi> wrote:
> +       /* TFRC-SP enforces a minimum interval of 10 milliseconds */
> +       hctx->ccid4hctx_t_ipi > +               max_t(u32, scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
> +                                       hctx->ccid4hctx_x),
> +                     10000);
>
I think this should be a constant. Otherwise fine.

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
