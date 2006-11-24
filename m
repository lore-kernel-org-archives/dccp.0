From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 24 Nov 2006 22:14:58 +0000
Subject: Re: [PATCH 3/6]: Fix calculation of t_ipi time of scheduled transmission
Message-Id: <5640c7e00611241414p46f4a955ud7ec8d9673b5bcc5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
In-Reply-To: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> |  Shouldn't that last line be rc = (delay-hctx->ccid3hctx_delta)/1000 as
> |  you're not taking the delta into account on the else clause.
>
> The value of `delay' is the difference between t_nom = t_(i+1) and t_now:
>
>         delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
>
> If this difference is less than delta (which includes the case when t_now is
> later than t_nom such that the difference is negative), then the packet is sent now.
>
> If the difference is greater than delta then t_now < t_nom and the packet is too early
> to be sent; [RFC 3448, 4.6] says to reschedule in
>
>           t_ipi - (t_now - t_i) = t_ipi - (t_now - t_i) = (t_i + t_ipi) - t_now
>                                                         = t_(i+1)       - t_now
>                                                         = t_nom         - t_now
>
> Hence we can reuse the timeval_delta. Maybe the variable should be renamed to highlight
> the fact that it is a time difference, but I quite liked `delay'.

OK. Understand now.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
