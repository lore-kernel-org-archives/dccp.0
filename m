From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 20:14:47 +0000
Subject: Re: [PATCH 1/11]: Auxiliary function for smallest-fit option lengths
Message-Id: <5640c7e00710011314ic79a74fw14d8af7ef060566f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.11436@strip-the-willow>
In-Reply-To: <200710011518.11436@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Auxiliary function for smallest-fit option lengths
>
> This introduces a function to determine the smallest-fit data type to carry options,
> which is used by the feature-negotiation code to insert option values.
>
> While doing this, I found that the same code is required to set the NDP length,
> whose length is variable between 1..6 bytes (RFC 4340, 7.7).
>
> There seem to be remains of the old code base when apparently NDP count was only 3
> bytes long. I have removed the annotations, as well as an unused constant limiting
> the maximum NDP value to 3 bytes, and added a FIXME to increase the data type for
> NDP up to u64. I didn't want to add this to this patch also, since various other
> parts (e.g. CCID3) implicitly rely on u32. For the moment, u32 seems to more than
> ample anyway, so the FIXME could even remain until there is a `high-speed' CCID.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
