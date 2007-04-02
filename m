From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 02 Apr 2007 09:06:09 +0000
Subject: Re: [PATCH 24/25]: Macro for moving average
Message-Id: <5640c7e00704020206v5073cbb8x7ce2ccec1cb10600@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211846.10823@strip-the-willow>
In-Reply-To: <200703211846.10823@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> |  > +/**
> |  > + * Macro for exponentially weighted moving average
> |  > + * @weight: Weight to be used as damping factor, in units of 1/10
> |  > + * Beware that @val is evaluated multiple times.
> |  > + */
> |  > +#define TFRC_EWMA(val, newval, weight) \
> |  > + val = val? ((weight) * val + (10 - (weight)) * (newval)) / 10 : (newval)
> |  > +
> |  Just wondering why you pass weight when you only use 9 anyway and it
> |  just adds a step. Is it used in following patches with a different
> |  weight?
> |
> In the following patches it is used one more time, which is for the `Preventing
> Oscillations' changeset (this is not in the next patch set but in the one after that);
> here again the weight 9/10 is used. I think it is useful to keep the `weight' argument,
> since RFC 3448 suggests to use a different weight for the RTT sample when the `Oscillation
> Prevention' e.g. is not deployed (a q close to zero).
> I think it is better to keep the weight argument, it allows changing the code later, while
> still providing the abstraction: for CCID 3 there are 4 uses of this macro alone.
>
OK.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
