From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 26 Mar 2007 04:04:31 +0000
Subject: Re: [PATCH 24/25]: Macro for moving average
Message-Id: <5640c7e00703252104p7732f077rb6eb549fb968896a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211846.10823@strip-the-willow>
In-Reply-To: <200703211846.10823@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/22/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Macro for moving average
>
> The moving average computation occurs so frequently in the CCID 3 code that
> it merits a macro of its own.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/ccids/ccid3.c    |    8 +++-----
>  net/dccp/ccids/lib/tfrc.h |    8 ++++++++
>  2 files changed, 11 insertions(+), 5 deletions(-)
>
> --- a/net/dccp/ccids/lib/tfrc.h
> +++ b/net/dccp/ccids/lib/tfrc.h
> @@ -37,6 +37,14 @@ static inline u32 scaled_div32(u64 a, u3
>         return result;
>  }
>
> +/**
> + * Macro for exponentially weighted moving average
> + * @weight: Weight to be used as damping factor, in units of 1/10
> + * Beware that @val is evaluated multiple times.
> + */
> +#define TFRC_EWMA(val, newval, weight) \
> +       val = val? ((weight) * val + (10 - (weight)) * (newval)) / 10 : (newval)
> +
Just wondering why you pass weight when you only use 9 anyway and it
just adds a step. Is it used in following patches with a different
weight?

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
