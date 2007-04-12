From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 14:14:15 +0000
Subject: Re: [PATCH 4/25]: Cheaper & smaller timestamping
Message-Id: <39e6f6c70704120714r543cb26ao134d86b24f53ffd0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.22972@strip-the-willow>
In-Reply-To: <200703211844.22972@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  > [DCCP]: Cheaper & smaller timestamping
>
> |  A couple of comments though:
> |  - this is how I had the code originally in many cases and Arnaldo
> |  changed - can't remember why.
> Arnaldo's code uses a reference point, the skb_get_timestamp() also did
> that. May be useful against old incarnations across reboots.

I got to this cset now in today's merge session, the cset that did that was:

b0e567806d16586629468c824dfb2e71155df7da

Comment was, unfortunately, not so clear:

----
[acme@mica net-2.6.22]$ git-show b0e567806d16586629468c824dfb2e71155df7da
commit b0e567806d16586629468c824dfb2e71155df7da
Author: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date:   Fri Sep 9 02:38:35 2005 -0300

    [DCCP] Introduce dccp_timestamp

    To start the timestamps with 0.0ms, easing the integer maths in
the CCIDs, this
    probably will be reworked to use the to be introduced struct timeval_offset
    infrastructure out of skb_get_timestamp, etc.

    Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---

What are the architectures you've been testing? All 64 bits? IIRC the
problem was related to overflows, suseconds_t is unsigned long, so 32
bits on i386...

> |  - we should be looking at using the new ktime as monotonic but that
> |  can be a task for another time.
> Excellent idea, this may allow to make CCID3 more precise.
>
> By sheer magic, skb_get_timestamp does this already, as I just saw:
>
> static inline void skb_get_timestamp(const struct sk_buff *skb, struct timeval *stamp)
> {
>         *stamp = ktime_to_timeval(skb->tstamp);
> }
>
> so we only need to replace the do_gettimeofday() at some time.

Yes, skb_get_timestamp seems to be the right thing to do, but now I'm
uneasy about applying the patch that essentially reverts
b0e567806d16586629468c824dfb2e71155df7da, will try not applying it and
applying the followup patches, will report the results soon.

- Arnaldo
