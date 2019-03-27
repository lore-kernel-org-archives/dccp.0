From: Mukesh Ojha <mojha@codeaurora.org>
Date: Wed, 27 Mar 2019 14:56:05 +0000
Subject: Re: [PATCH v3] dccp: Fix memleak in __feat_register_sp
Message-Id: <120ffaa7-0e53-7a19-7fbf-898275ff3dab@codeaurora.org>
List-Id: <dccp.vger.kernel.org>
References: <20190325024106.10808-1-yuehaibing@huawei.com>
In-Reply-To: <20190325024106.10808-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


On 3/25/2019 8:11 AM, Yue Haibing wrote:
> From: YueHaibing <yuehaibing@huawei.com>
>
> If dccp_feat_push_change fails, we forget free the mem
> which is alloced by kmemdup in dccp_feat_clone_sp_val.
>
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Fixes: e8ef967a54f4 ("dccp: Registration routines for changing feature values")
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>


Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>

-Mukesh

> ---
> v3: fix compile issue, sorry for this again
> v2: kfree 'val --> 'fval'
> ---
>   net/dccp/feat.c | 7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/net/dccp/feat.c b/net/dccp/feat.c
> index f227f00..db87d9f 100644
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -738,7 +738,12 @@ static int __feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
>   	if (dccp_feat_clone_sp_val(&fval, sp_val, sp_len))
>   		return -ENOMEM;
>   
> -	return dccp_feat_push_change(fn, feat, is_local, mandatory, &fval);
> +	if (dccp_feat_push_change(fn, feat, is_local, mandatory, &fval)) {
> +		kfree(fval.sp.vec);
> +		return -ENOMEM;
> +	}
> +
> +	return 0;
>   }
>   
>   /**
