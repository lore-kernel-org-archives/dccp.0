From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 14:55:05 +0000
Subject: Re: [PATCH 1/3]: Inline for time delta
Message-Id: <39e6f6c70706160755r5100f479rfdb3e2f8ce8782fc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091932.15559@strip-the-willow>
In-Reply-To: <200706091932.15559@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/16/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  > The name was chosen for consistency with timeval_delta(), which is the current
> |  > function for microsecond time differences in net/dccp/dccp.h.
> |
> |  I'm going to rename ktime_delta() to ktime_us_delta(), as it receives
> |  two ktime_t values, but returns a delta in microseconds, not in
> |  ktime_t.
> I am going to change that in my tree as well, since I am busy updating with regard
> to most recent changes anyway.

I just checked with Thomas Gleixner, the ktime_t guy and he is ok with
adding ktime_us_delta() to ktime.h, which I have in my tree already.

I'm now staring at this:
   /* set the nominal send time for the next following packet */
-        timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
+       hctx->ccid3hctx_t_nom = ktime_add_ns(hctx->ccid3hctx_t_nom,
+                                            hctx->ccid3hctx_t_ipi * 1000);

I'm thinking about just keeping t_ipi in nanoseconds to avoid doing
the multiplies back and forth, but haven't fully looked at the other
t_ipi uses, quick thoughts? Stupid idea?

- Arnaldo
