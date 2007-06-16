From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 16 Jun 2007 16:45:09 +0000
Subject: Re: [PATCH 3/3]: Update computation of X to use newer timeofday interface
Message-Id: <200706161745.09351@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091933.09514@strip-the-willow>
In-Reply-To: <200706091933.09514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  We'll have to avoid it, I'm looking at how to do it...
|  
|  
|  I'm just stuck with t_ld not having being converted to ktime_t, so
|  I'll fix this up by...
|  
|  -                       hctx->ccid3hctx_t_ld = now;
|  +                       hctx->ccid3hctx_t_ld = ktime_to_timeval(now);
|  
|  With this the second patch builds, now to look at the 3rd.
|  
|  
|  Gerrit, have you ever used git-bisect? Think about what people that
|  build distro kernels, where our DCCP stuff is built, will think about
|  us when doing a bisect to find the changeset that introduced a bug in
|  a completely unrelated area such as sysrq+M oopsing on machines with
|  sparse memory maps (example: myself last week 8) ) and the build
|  breaks because of such patch interdependency...
|  
|  So I'll try to help you in finding ways for never, ever having the
|  tree not building at any point in time.
|  
|  This is OK when in a rush and in a private tree, not in something that
|  we expect to merge :-)
In that case please don't consider these patches for merging. I may not
have been clear, but these patches are first and foremost destined for
the experimental tree, and there are still 12 patches outstanding.

I.e. you are trying to build on something which is not yet complete.

We had these inter-dependencies before and they have been giving me (and
from what I read not only me) a lot of hell. It is all inter-related
and it is extremely hard to make patches both readable, split in logical
units, and compile as well.

I agree with your point, but trying to dissect these patches while in the
middle of a submission is madness. 

My idea was to put that into the test tree and offer it for testing.

I myself have been testing this code for 4..5 months now with good results.

I appreciate your help but I think this patch set can wait - at least until
I have had time to submit the rest, please.

Thanks.
