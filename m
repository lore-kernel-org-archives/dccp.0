From: Richard Sailer <richard_siegfried@systemli.org>
Date: Thu, 10 Jun 2021 16:44:35 +0000
Subject: Re: [PATCH -next] dccp: tfrc: fix doc warnings in tfrc_equation.c
Message-Id: <1ef2e838-5cf9-c121-624d-3c6e5d5f1649@systemli.org>
List-Id: <dccp.vger.kernel.org>
References: <20210610132603.597563-1-libaokun1@huawei.com>
In-Reply-To: <20210610132603.597563-1-libaokun1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Just adds a correct comment. Looks fine to me.

Reviewed-by: Richard Sailer <richard_siegfried@systemli.org>

On 10/06/2021 15:26, Baokun Li wrote:
> Add description for `tfrc_invert_loss_event_rate` to fix the W=1 warnings:
> 
>   net/dccp/ccids/lib/tfrc_equation.c:695: warning: Function parameter or
>    member 'loss_event_rate' not described in 'tfrc_invert_loss_event_rate'
> 
> Signed-off-by: Baokun Li <libaokun1@huawei.com>
> ---
>   net/dccp/ccids/lib/tfrc_equation.c | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/net/dccp/ccids/lib/tfrc_equation.c b/net/dccp/ccids/lib/tfrc_equation.c
> index e2a337fa9ff7..92a8c6bea316 100644
> --- a/net/dccp/ccids/lib/tfrc_equation.c
> +++ b/net/dccp/ccids/lib/tfrc_equation.c
> @@ -688,6 +688,7 @@ u32 tfrc_calc_x_reverse_lookup(u32 fvalue)
>   
>   /**
>    * tfrc_invert_loss_event_rate  -  Compute p so that 10^6 corresponds to 100%
> + * @loss_event_rate: loss event rate to invert
>    * When @loss_event_rate is large, there is a chance that p is truncated to 0.
>    * To avoid re-entering slow-start in that case, we set p = TFRC_SMALLEST_P > 0.
>    */
> 
