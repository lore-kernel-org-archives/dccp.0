From: David Miller <davem@davemloft.net>
Date: Tue, 02 Apr 2019 01:16:41 +0000
Subject: Re: [PATCH] dccp: Fix memleak in __feat_register_sp
Message-Id: <20190401.181641.1589135999760609672.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20190321141058.14580-1-yuehaibing@huawei.com>
In-Reply-To: <20190321141058.14580-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Yue Haibing <yuehaibing@huawei.com>
Date: Mon, 1 Apr 2019 09:35:54 +0800

> From: YueHaibing <yuehaibing@huawei.com>
> 
> If dccp_feat_push_change fails, we forget free the mem
> which is alloced by kmemdup in dccp_feat_clone_sp_val.
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Fixes: e8ef967a54f4 ("dccp: Registration routines for changing feature values")
> Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>

Applied.
