From: David Miller <davem@davemloft.net>
Date: Tue, 09 Jun 2020 20:27:36 +0000
Subject: Re: [PATCH] dccp: Fix possible memleak in dccp_init and dccp_fini
Message-Id: <20200609.132736.1760843725831249479.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20200609141816.33467-1-wanghai38@huawei.com>
In-Reply-To: <20200609141816.33467-1-wanghai38@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Wang Hai <wanghai38@huawei.com>
Date: Tue, 9 Jun 2020 22:18:16 +0800

> There are some memory leaks in dccp_init() and dccp_fini().
> 
> In dccp_fini() and the error handling path in dccp_init(), free lhash2
> is missing. Add inet_hashinfo2_free_mod() to do it.
> 
> If inet_hashinfo2_init_mod() failed in dccp_init(),
> percpu_counter_destroy() should be called to destroy dccp_orphan_count.
> It need to goto out_free_percpu when inet_hashinfo2_init_mod() failed.
> 
> Fixes: c92c81df93df ("net: dccp: fix kernel crash on module load")
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: Wang Hai <wanghai38@huawei.com>

Applied and queued up for -stable, thank you.
