From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Apr 2007 08:48:12 +0000
Subject: Re: [PATCH 10/25]: Shorten statement for updating p
Message-Id: <200704020948.13093@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.54487@strip-the-willow>
In-Reply-To: <200703211844.54487@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > +       /* Update loss event rate (scaled by 1e6), cf. RFC 4342, 8.5 */
|  >         pinv = opt_recv->ccid3or_loss_event_rate;
|  > -       if (pinv = ~0U || pinv = 0)          /* see RFC 4342, 8.5   */
|  > -               hctx->ccid3hctx_p = 0;
|  > -       else                                   /* can not exceed 100% */
|  > -               hctx->ccid3hctx_p = 1000000 / pinv;
|  > +       hctx->ccid3hctx_p = (pinv = ~0U || pinv = 0)? 0 : scaled_div(1, pinv);
|  >
|  
|  Agree with the scaled_div bit but don't like removing if/then and
|  repalce withing ?: as harder to read and compiler can optimise just as
|  well. Matter of personal choice though so up to Arnaldo really.
|  
I could take this patch out if you / Arnaldo think so, since it is overridden later
by another patch which uses only one socket field instead of two (p depends on pinv,
so having both is redundant).
Please let me be state this - I aim as best as possible to avoid overlap and overriding
in later patches. But this is not always possible and - having just spent almost two
days integrating away another patch set with my local changesets - can sometimes be
a real nightmare. It is not always avoidable when trying to split larger changes into 
small and separate chunks. 
