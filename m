From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 15:12:27 +0000
Subject: Re: [PATCH 1/3]: Inline for time delta
Message-Id: <39e6f6c70706160812l5e1f6187qf5fe2c1b537f5199@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091932.15559@strip-the-willow>
In-Reply-To: <200706091932.15559@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/16/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  > I am going to change that in my tree as well, since I am busy updating with regard
> |  > to most recent changes anyway.
> |
> |  I just checked with Thomas Gleixner, the ktime_t guy and he is ok with
> |  adding ktime_us_delta() to ktime.h, which I have in my tree already.
> Ok when that comes through, the patch can simply be dropped.
>
> |  I'm now staring at this:
> |   /* set the nominal send time for the next following packet */
> |  - timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
> |  + hctx->ccid3hctx_t_nom = ktime_add_ns(hctx->ccid3hctx_t_nom,
> |  + hctx->ccid3hctx_t_ipi * 1000);
> |
> |  I'm thinking about just keeping t_ipi in nanoseconds to avoid doing
> |  the multiplies back and forth, but haven't fully looked at the other
> |  t_ipi uses, quick thoughts? Stupid idea?
> Please keep it for the moment. The packet scheduler needs an overhaul in any case,
> so the above IMO is the simplest way of aligning the old code with the new interface.
>
> Overhauling the packet scheduler will cost some work, but it is one of the next items
> that should be addressed when through with the current set of patches.

OK! I'm just adding this to ktime.h:

static inline ktime_t ktime_add_us(const ktime_t kt, const u64 usec)
{
        return ktime_add_ns(kt, usec * 1000);
}

And will use it where needed.

- Arnaldo
