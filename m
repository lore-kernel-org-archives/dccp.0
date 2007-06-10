From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 10 Jun 2007 05:55:52 +0000
Subject: Re: [PATCH 1/3]: Inline for time delta
Message-Id: <5640c7e00706092255l6c6167f5oe15c57158555e91@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091932.15559@strip-the-willow>
In-Reply-To: <200706091932.15559@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Inline for time delta
>
> This provides a reusable time difference function which returns the difference in
> microseconds, as often used in the DCCP code.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/dccp.h |    5 +++++
>  1 file changed, 5 insertions(+)
>
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -421,6 +421,11 @@ static inline suseconds_t timeval_delta(
>         return secs * USEC_PER_SEC + usecs;
>  }
>
> +static inline s64 ktime_delta(ktime_t later, ktime_t earlier)
> +{
> +       return ktime_to_us(ktime_sub(later, earlier));
> +}
> +
>  static inline void timeval_add_usecs(struct timeval *tv,
>                                      const suseconds_t usecs)
>  {

Judging from patches I've seen rejected recently I'd say this should
be shifted into the same place as ktime_sub is defined. Also rename to
ktime_sub_us.

I know that it sounds like I'm being a pain but I've seen a few like
this rejected recently.

Great to see patches moving ahead again.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
