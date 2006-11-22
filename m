From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 22 Nov 2006 17:59:37 +0000
Subject: Re: [PATCH 3/6]: Fix calculation of t_ipi time of scheduled transmission
Message-Id: <5640c7e00611220959k4ca67a28yed1e119d6192af6c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
In-Reply-To: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>     * the packet is sent now whenever t_now >= t_nom + t_delta
>       instead of                      t_now >  t_nom - t_delta
>       => this incurs a performance degradation, since 2*t_delta is spent unnecessarily
>
Yes you are right here. This is a bug

> +                * if (t_now > t_nom - delta)
> +                *       // send the packet now
> +                * else
> +                *       // send the packet in (t_nom - t_now) milliseconds.
> +                */
> +               if (delay < hctx->ccid3hctx_delta)
> +                       rc = 0;
> +               else
> +                       rc = delay/1000L;

Shouldn't that last line be rc = (delay-hctx->ccid3hctx_delta)/1000 as
you're not taking the delta into account on the else clause.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
