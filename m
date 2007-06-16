From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 14:04:46 +0000
Subject: Re: [PATCH 1/3]: Inline for time delta
Message-Id: <39e6f6c70706160704n1f342dd6nd1a852b19f680982@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091932.15559@strip-the-willow>
In-Reply-To: <200706091932.15559@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/11/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> |  > --- a/net/dccp/dccp.h
> |  > +++ b/net/dccp/dccp.h
> |  > @@ -421,6 +421,11 @@ static inline suseconds_t timeval_delta(
> |  > return secs * USEC_PER_SEC + usecs;
> |  > }
> |  >
> |  > +static inline s64 ktime_delta(ktime_t later, ktime_t earlier)
> |  > +{
> |  > + return ktime_to_us(ktime_sub(later, earlier));
> |  > +}
> |  > +
> |  > static inline void timeval_add_usecs(struct timeval *tv,
> |  > const suseconds_t usecs)
> |  > {
> |
> |  Judging from patches I've seen rejected recently I'd say this should
> |  be shifted into the same place as ktime_sub is defined. Also rename to
> |  ktime_sub_us.
> |
> ktime_sub is defined in include/linux/ktime.h - the file only contains generic
> definitions, everything is in nanoseconds, struct timeval, or struct timespec.
>
> The other place is include/linux/skbuff.h, where net_timedelta() is defined.
> This is probably due to the skb->tstamp field - as a utility function to be used
> with skbs.
>
> Neither place seems appropriate for above function, it is more specific than the
> ones in ktime.h. I am at a loss where else if not the DCCP code, where it is
> specifically used, to place it.
>
> The name was chosen for consistency with timeval_delta(), which is the current
> function for microsecond time differences in net/dccp/dccp.h.

I'm going to rename ktime_delta() to ktime_us_delta(), as it receives
two ktime_t values, but returns a delta in microseconds, not in
ktime_t.

Don't worry, I'll fixup the later patches, after a while we get
everything sorted out.

- Arnaldo
