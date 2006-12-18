From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 18 Dec 2006 08:23:26 +0000
Subject: Re: [PATCH 5/8]: Move debugging macro to header file
Message-Id: <5640c7e00612180023u28675735sabb082d209979436@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
In-Reply-To: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

OK. Go to use this in net/dccp/ccids/lib/loss_interval.c and get this:
WARNING: "ccid3_debug" [net/dccp/ccids/lib/dccp_tfrc_lib.ko] undefined!

So I think I'll just do this in ccid3.c
EXPORT_SYMBOL_GPL(ccid3_debug);

and now I get this:
WARNING: Module
/lib/modules/2.6.20-rc1davem20/kernel/net/dccp/ccids/lib/dccp_tfrc_lib.ko
ignored, due to loop
WARNING: Loop detected:
/home/ian/tmp/lib/modules/2.6.20-rc1davem20/kernel/net/dccp/ccids/dccp_ccid3.ko
needs dccp_tfrc_lib.ko which needs dccp_ccid3.ko again!
WARNING: Module
/lib/modules/2.6.20-rc1davem20/kernel/net/dccp/ccids/dccp_ccid3.ko
ignored, due to loop

Hmm... what to do now? These need refactoring anyway but I was hoping
not to have to do that now.

Regards,

Ian

On 12/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Move debugging macro to header file
>
> This moves the ccid3_pr_debug macro into the header file,
> so that it can be used from other files belonging to the
> CCID3 framework as well.
>
> Thanks to Ian McDonald for the suggestion.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -41,13 +41,6 @@
>  #include "lib/tfrc.h"
>  #include "ccid3.h"
>
> -#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
> -static int ccid3_debug;
> -#define ccid3_pr_debug(format, a...)   DCCP_PR_DEBUG(ccid3_debug, format, ##a)
> -#else
> -#define ccid3_pr_debug(format, a...)
> -#endif
> -
>  static struct dccp_tx_hist *ccid3_tx_hist;
>  static struct dccp_rx_hist *ccid3_rx_hist;
>  static struct dccp_li_hist *ccid3_li_hist;
> @@ -1227,6 +1220,7 @@ static struct ccid_operations ccid3 = {
>  };
>
>  #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
> +int ccid3_debug;
>  module_param(ccid3_debug, int, 0444);
>  MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
>  #endif
> --- a/net/dccp/ccids/ccid3.h
> +++ b/net/dccp/ccids/ccid3.h
> @@ -61,6 +61,13 @@
>                         rtt = CCID3_SANE_RTT_MAX;                          \
>                 }                                       } while (0)
>
> +#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
> +extern int ccid3_debug;
> +#define ccid3_pr_debug(format, a...)   DCCP_PR_DEBUG(ccid3_debug, format, ##a)
> +#else
> +#define ccid3_pr_debug(format, a...)
> +#endif
> +
>  enum ccid3_options {
>         TFRC_OPT_LOSS_EVENT_RATE = 192,
>         TFRC_OPT_LOSS_INTERVALS  = 193,
> -

-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
