From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 28 Sep 2007 18:21:50 +0000
Subject: Re: [PATCH 2/9]: Query supported CCIDs
Message-Id: <20070928182150.GA23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.17307@strip-the-willow>
In-Reply-To: <200709281630.17307@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Sep 28, 2007 at 04:30:17PM +0100, Gerrit Renker escreveu:
> [DCCP]: Query supported CCIDs
> 
> This provides a data structure to record which CCIDs are locally supported
> and three accessor functions:
>  - a test function for internal use which is used to validate CCID requests
>    made by the user;
>  - a copy function so that the list can be used for feature-negotiation;   
>  - documented getsockopt() support so that the user can query capabilities.
> 
> The data structure is a table which is filled in at compile-time with the
> list of available CCIDs (which in turn depends on the Kconfig choices).
> 
> Using the copy function for cloning the list of supported CCIDs is useful for
> feature negotiation, since the negotiation is now with the full list of available
> CCIDs (e.g. {2, 3}) instead of the default value {2}. This means negotiation will
> not fail if the peer requests to use CCID3 instead of CCID2. 
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  Documentation/networking/dccp.txt |    4 +++
>  include/linux/dccp.h              |    1 
>  net/dccp/ccid.c                   |   48 ++++++++++++++++++++++++++++++++++++++
>  net/dccp/ccid.h                   |    5 +++
>  net/dccp/feat.c                   |    4 +++
>  net/dccp/proto.c                  |    2 +
>  6 files changed, 64 insertions(+)
> 
> --- a/net/dccp/ccid.h
> +++ b/net/dccp/ccid.h
> @@ -80,6 +80,11 @@ static inline void *ccid_priv(const stru
>  	return (void *)ccid->ccid_priv;
>  }
>  
> +extern int  ccid_get_default_ccids(u8 **ccid_array, u8 *array_len);
> +extern bool ccid_support_check(u8 const *ccid_array, u8 array_len);
> +extern int  ccid_getsockopt_available_ccids(struct sock *sk, int len,
> +					    char __user *, int __user *);
> +
>  extern struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx,
>  			     gfp_t gfp);
>  
> --- a/net/dccp/ccid.c
> +++ b/net/dccp/ccid.c
> @@ -13,6 +13,13 @@
>  
>  #include "ccid.h"
>  
> +static u8 builtin_ccids[] = {
> +	DCCPC_CCID2,		/* CCID2 is supported by default */
> +#if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
> +	DCCPC_CCID3,
> +#endif
> +};

This considers only code that was already merged. What about a new CCID
that is not yet merged? I guess the table should be managed at ccid
module registration time... but that would prevent autoloading on
demand, so I think that a sysctl interface that tells the DCCP core
infrastructure which are the ccids that are available is better.

Think also about an administrator deciding that even with the Linux
kernel provided by his vendor containing modules for ccid2, 3, etc, he
only accepts ccid3 or some other subset.

We could have as default a table built with the modules we know at dccp
core build time to be available in the current kernel build, but not
prevent others from being added or existing ones to be disabled.

So I think we can start with what you provided and implement my
suggestions later.

- Arnaldo
