From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 16:55:59 +0000
Subject: Re: [PATCH 3/3]: Update computation of X to use newer timeofday interface
Message-Id: <39e6f6c70706160955g4953404alcfc90b6c8fff081b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091933.09514@strip-the-willow>
In-Reply-To: <200706091933.09514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/16/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  We'll have to avoid it, I'm looking at how to do it...
> |
> |
> |  I'm just stuck with t_ld not having being converted to ktime_t, so
> |  I'll fix this up by...
> |
> |  - hctx->ccid3hctx_t_ld = now;
> |  + hctx->ccid3hctx_t_ld = ktime_to_timeval(now);
> |
> |  With this the second patch builds, now to look at the 3rd.
> |
> |
> |  Gerrit, have you ever used git-bisect? Think about what people that
> |  build distro kernels, where our DCCP stuff is built, will think about
> |  us when doing a bisect to find the changeset that introduced a bug in
> |  a completely unrelated area such as sysrq+M oopsing on machines with
> |  sparse memory maps (example: myself last week 8) ) and the build
> |  breaks because of such patch interdependency...
> |
> |  So I'll try to help you in finding ways for never, ever having the
> |  tree not building at any point in time.
> |
> |  This is OK when in a rush and in a private tree, not in something that
> |  we expect to merge :-)
> In that case please don't consider these patches for merging. I may not
> have been clear, but these patches are first and foremost destined for
> the experimental tree, and there are still 12 patches outstanding.

OK, but doing the simple ktime_to_timeval above I was able to merge
something that moves us further, its clear and self contained, so I
loved it and merged.

>
> I.e. you are trying to build on something which is not yet complete.

I made it self contained (the second patch), split it so that the one
after it fixes the bug you described, which improves what we have in
the tree.

> We had these inter-dependencies before and they have been giving me (and
> from what I read not only me) a lot of hell. It is all inter-related
> and it is extremely hard to make patches both readable, split in logical
> units, and compile as well.

I know,

> I agree with your point, but trying to dissect these patches while in the
> middle of a submission is madness.

Hey, think that what we're doing is: you're working on the
experimental tree, I'm trying to cherry pick what I think its small,
self contained and fixes things, reducing the size of the experimental
tree.

> My idea was to put that into the test tree and offer it for testing.
>
> I myself have been testing this code for 4..5 months now with good results.

Thank you for that!

> I appreciate your help but I think this patch set can wait - at least until
> I have had time to submit the rest, please.

I'll continue reading it, and will discuss with you in advance the
ones I think I can merge, ok?

- Arnaldo
