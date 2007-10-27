From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 27 Oct 2007 22:23:34 +0000
Subject: Re: [PATCH 4/6]: Don't assign negative values to Ack Ratio
Message-Id: <5640c7e00710271523g6c51b73btdff345932a373560@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710271234.32415@strip-the-willow>
In-Reply-To: <200710271234.32415@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Don't process Ack twice in Respond state
>
Is this patch been posted twice. There are two patches in this email...

> [CCID2]: Don't assign negative values to Ack Ratio
>
> Since it makes not sense to assign negative values to Ack Ratio, this
> patch disallows this possibility.
>
> As a consequence, a Bug test for negative Ack Ratio values becomes obsolete.
>
> Furthermore, a check against overflow (as Ack Ratio may not exceed 2 bytes,
> due to RFC 4340, 11.3) has been added.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
