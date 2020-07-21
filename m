From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Date: Tue, 21 Jul 2020 02:40:16 +0000
Subject: Re: [PATCH 02/24] bpfilter: fix up a sparse annotation
Message-Id: <20200721024016.2talwdt5hjqvirr6@ltop.local>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-3-hch@lst.de>
In-Reply-To: <20200720124737.118617-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Jul 20, 2020 at 02:47:15PM +0200, Christoph Hellwig wrote:
> The __user doesn't make sense when casting to an integer type.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  net/bpfilter/bpfilter_kern.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
> index 977e9dad72ca4f..713b4b3d02005d 100644
> --- a/net/bpfilter/bpfilter_kern.c
> +++ b/net/bpfilter/bpfilter_kern.c
> @@ -49,7 +49,7 @@ static int __bpfilter_process_sockopt(struct sock *sk, int optname,
>  	req.is_set = is_set;
>  	req.pid = current->pid;
>  	req.cmd = optname;
> -	req.addr = (long __force __user)optval;
> +	req.addr = (__force long)optval;

For casts to integers, even '__force' is not needed (since integers
can't be dereferenced, the concept of address-space is meaningless
for them, so it's never useful to warn when it's dropped and
'__force' is thus not needed).

-- Luc
