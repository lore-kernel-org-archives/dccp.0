From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 18 Dec 2013 02:38:36 +0000
Subject: Re: [PATCH 1/1][net-next] dccp: catch failed request_module call in dccp_probe init
Message-Id: <52B10AAC.3070400@huawei.com>
List-Id: <dccp.vger.kernel.org>
References: <20131217192433.168b39ef@liptov.cs.ualberta.ca>
In-Reply-To: <20131217192433.168b39ef@liptov.cs.ualberta.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2013/12/18 10:24, Gerrit Renker wrote:
> Hi Wang,
> 
> thank you for the patch, please find refactored version below, changes are
>  (a) if request_module fails, return its error code instead of the previous ret,
>  (b) refactor code -- setup_jprobe becomes superfluous.
> 
> Please add your signed off if ok, since it is essentially your patch.
> 
>>>>>>>>>>>>>>>>>>>>>>>> Wang's patch revised <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp: catch failed request_module call in dccp_probe init
> 
> Check the return value of request_module during dccp_probe initialisation,
> bail out if that call fails.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/probe.c |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
> 
> --- a/net/dccp/probe.c
> +++ b/net/dccp/probe.c
> @@ -152,17 +152,6 @@ static const struct file_operations dccp
>  	.llseek  = noop_llseek,
>  };
>  
> -static __init int setup_jprobe(void)
> -{
> -	int ret = register_jprobe(&dccp_send_probe);
> -
> -	if (ret) {
> -		request_module("dccp");
> -		ret = register_jprobe(&dccp_send_probe);
> -	}
> -	return ret;
> -}
> -
>  static __init int dccpprobe_init(void)
>  {
>  	int ret = -ENOMEM;
> @@ -174,7 +163,13 @@ static __init int dccpprobe_init(void)
>  	if (!proc_create(procname, S_IRUSR, init_net.proc_net, &dccpprobe_fops))
>  		goto err0;
>  
> -	ret = setup_jprobe();
> +	ret = register_jprobe(&dccp_send_probe);
> +	if (ret) {
> +		ret = request_module("dccp");
> +		if (!ret)
> +			ret = register_jprobe(&dccp_send_probe);
> +	}
> +
>  	if (ret)
>  		goto err1;
>  
> 
> 

It is OK.
Thanks.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>



