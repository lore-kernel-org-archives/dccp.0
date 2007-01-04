From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 04 Jan 2007 21:49:28 +0000
Subject: Re: [PATCH 1/5]: DCCP Fix use of invalid loss intervals
Message-Id: <459D7668.4050602@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200612201544.22122.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201544.22122.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian (catching up slowly slowly), here is a nit as nitty as they come.

This diff seems strange to me, since ~ actually does the same thing on 
integers and unsigned integers.  (This code:

     printf("%u %u\n", ~0, ~0U);

will print the same thing twice.)

Perhaps dccplih_interval is a 64-bit number?  In which case you want to 
say something like ~0ULL?

Eddie


Ian McDonald wrote:
> I've been trying to fix up performance for CCID3 and found this little
> bug that means the comparison was invalid and we were using invalid loss
> intervals when we shouldn't of.
> 
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
> diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
> index 0a0baef..372d7e7 100644
> --- a/net/dccp/ccids/lib/loss_interval.c
> +++ b/net/dccp/ccids/lib/loss_interval.c
> @@ -91,7 +91,7 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
>  	u32 w_tot  = 0;
>  
>  	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
> -		if (li_entry->dccplih_interval != ~0) {
> +		if (li_entry->dccplih_interval != ~0U) {
>  			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
>  			w_tot  += dccp_li_hist_w[i];
>  			if (i != 0)
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
