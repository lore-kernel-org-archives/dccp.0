From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 03 Nov 2007 22:00:59 +0000
Subject: Re: [PATCH 1/9] [CCID2]: Disable broken Ack Ratio adaptation algorithm
Message-Id: <5640c7e00711031500p74cd528fs15800beb11ebfad1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031323.36246@strip-the-willow>
In-Reply-To: <200711031323.36246@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This comments out a problematic section comprising a half-finished algorithm:
>
>  - The variable `ccid2hctx_ackloss' is never initialised to a value different from 0 and
>    hence in fact is a read-only constant.
>  - The `arsent' variable counts packets other than Acks (it is incremented for every packet),
>    and there is no test for Ack Loss.
>  - The concept of counting Acks as such leads to a complex calculation, and the calculation
>    at the moment is inconsistent with this concept.
>    The problem is that the number of Acks - rather than the number of windows - is counted,
>    which leads to a complex (cubic/quadratic) expression - this is not even implemented.
>
> In its current state, the commented-out algorithm interferes with normal processing by
> changing Ack Ratio incorrectly, and at the wrong times.
>
> A new algorithm is necessary, which will not necessarily use the same variables as used by
> the unfinished one; hence the old variables have been removed.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
