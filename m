From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 14 May 2014 10:01:14 +0000
Subject: Re: [PATCH net-next] dccp: make the request_retries minimum is 1
Message-Id: <20140514040120.31c13b73@199-7-159-29.eng.wind.ca>
List-Id: <dccp.vger.kernel.org>
References: <53718A36.1040907@huawei.com>
In-Reply-To: <53718A36.1040907@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>


> ---
>  net/dccp/sysctl.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
> index 607ab71..53731e4 100644
> --- a/net/dccp/sysctl.c
> +++ b/net/dccp/sysctl.c
> @@ -20,6 +20,7 @@
>  
>  /* Boundary values */
>  static int		zero     = 0,
> +			one      = 1,
>  			u8_max   = 0xFF;
>  static unsigned long	seqw_min = DCCPF_SEQ_WMIN,
>  			seqw_max = 0xFFFFFFFF;		/* maximum on 32 bit */
> @@ -58,7 +59,7 @@ static struct ctl_table dccp_default_table[] = {
>  		.maxlen		= sizeof(sysctl_dccp_request_retries),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
> -		.extra1		= &zero,
> +		.extra1		= &one,
>  		.extra2		= &u8_max,
>  	},
>  	{

