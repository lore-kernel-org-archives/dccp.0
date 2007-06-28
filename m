From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 28 Jun 2007 00:30:24 +0000
Subject: Re: [PATCH 8/9]: Fix and simplify header includes
Message-Id: <5640c7e00706271730g1f20ddf8u93d3c7fe334407ba@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706171354.38717@strip-the-willow>
In-Reply-To: <200706171354.38717@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/18/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [TFRC]: Fix and simplify header includes
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> --- a/net/dccp/ccids/lib/tfrc.h
> +++ b/net/dccp/ccids/lib/tfrc.h
> @@ -16,6 +16,11 @@
>  #include <linux/types.h>
>  #include <asm/div64.h>
>  #include "../../dccp.h"
> +/* internal includes that this module exports: */
> +struct tfrc_rx_hist;
> +struct tfrc_loss_hist;
> +#include "loss_interval.h"
> +#include "packet_history.h"
>

Variable definitions in the middle of an include block? Is that
necessary? I just haven't seen that done before and it looks a little
odd...

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
