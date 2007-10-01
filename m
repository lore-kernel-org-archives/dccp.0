From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 01 Oct 2007 14:47:51 +0000
Subject: Re: [PATCH 1/11]: Auxiliary function for smallest-fit option
Message-Id: <20071001144751.GB5648@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.11436@strip-the-willow>
In-Reply-To: <200710011518.11436@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Oct 01, 2007 at 03:18:11PM +0100, Gerrit Renker escreveu:
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
> ---
>  include/linux/dccp.h |    4 +---
>  net/dccp/feat.h      |    8 ++++++++
>  net/dccp/options.c   |   13 ++++++-------
>  3 files changed, 15 insertions(+), 10 deletions(-)
> 
> --- a/net/dccp/feat.h
> +++ b/net/dccp/feat.h
> @@ -112,4 +112,12 @@ extern int  dccp_feat_clone(struct sock 
>  extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
>  extern int  dccp_feat_init(struct sock *sk);
>  
> +/* Find smallest-fit for @value, but not more than 6 bytes (current maximum) */
> +static inline u8 dccp_bytes_per_value(const u64 value)
> +{
> +	if (value > 0xFFFFFFFFull)
> +		return 6;
> +	return value > 0xFFFF? 4 : (value > 0xFF? 2 : 1);

Gerrit, one more coding style request: please always add an space after
the '?'.

- Arnaldo
