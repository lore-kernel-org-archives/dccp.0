From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 17 Sep 2020 08:03:35 +0000
Subject: Re: [oss-drivers] [trivial PATCH] treewide: Convert switch/case fallthrough; to break;
Message-Id: <20200917080334.GB5769@netronome.com>
List-Id: <dccp.vger.kernel.org>
References: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
In-Reply-To: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Sep 09, 2020 at 01:06:39PM -0700, Joe Perches wrote:
> fallthrough to a separate case/default label break; isn't very readable.
> 
> Convert pseudo-keyword fallthrough; statements to a simple break; when
> the next label is case or default and the only statement in the next
> label block is break;
> 
> Found using:
> 
> $ grep-2.5.4 -rP --include=*.[ch] -n "fallthrough;(\s*(case\s+\w+|default)\s*:\s*){1,7}break;" *
> 
> Miscellanea:
> 
> o Move or coalesce a couple label blocks above a default: block.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

...

> diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
> index 252fe06f58aa..1d5b87079104 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
> +++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
> @@ -345,7 +345,7 @@ static int matching_bar(struct nfp_bar *bar, u32 tgt, u32 act, u32 tok,
>  		baract = NFP_CPP_ACTION_RW;
>  		if (act = 0)
>  			act = NFP_CPP_ACTION_RW;
> -		fallthrough;
> +		break;
>  	case NFP_PCIE_BAR_PCIE2CPP_MapType_FIXED:
>  		break;
>  	default:

This is a cascading fall-through handling all map types.
I don't think this change improves readability.

...
