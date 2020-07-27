From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 27 Jul 2020 15:03:10 +0000
Subject: Re: [PATCH 12/26] netfilter: switch nf_setsockopt to sockptr_t
Message-Id: <20200727150310.GA1632472@zx2c4.com>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-13-hch@lst.de>
In-Reply-To: <20200723060908.50081-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Christoph,

On Thu, Jul 23, 2020 at 08:08:54AM +0200, Christoph Hellwig wrote:
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index da933f99b5d517..42befbf12846c0 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -1422,7 +1422,8 @@ int ip_setsockopt(struct sock *sk, int level,
>  			optname != IP_IPSEC_POLICY &&
>  			optname != IP_XFRM_POLICY &&
>  			!ip_mroute_opt(optname))
> -		err = nf_setsockopt(sk, PF_INET, optname, optval, optlen);
> +		err = nf_setsockopt(sk, PF_INET, optname, USER_SOCKPTR(optval),
> +				    optlen);
>  #endif
>  	return err;
>  }
> diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
> index 4697d09c98dc3e..f2a9680303d8c0 100644
> --- a/net/ipv4/netfilter/ip_tables.c
> +++ b/net/ipv4/netfilter/ip_tables.c
> @@ -1102,7 +1102,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
>  }
>  
>  static int
> -do_replace(struct net *net, const void __user *user, unsigned int len)
> +do_replace(struct net *net, sockptr_t arg, unsigned int len)
>  {
>  	int ret;
>  	struct ipt_replace tmp;
> @@ -1110,7 +1110,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
>  	void *loc_cpu_entry;
>  	struct ipt_entry *iter;
>  
> -	if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
> +	if (copy_from_sockptr(&tmp, arg, sizeof(tmp)) != 0)
>  		return -EFAULT;
>  
>  	/* overflow check */
> @@ -1126,8 +1126,8 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
>  		return -ENOMEM;
>  
>  	loc_cpu_entry = newinfo->entries;
> -	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
> -			   tmp.size) != 0) {
> +	sockptr_advance(arg, sizeof(tmp));
> +	if (copy_from_sockptr(loc_cpu_entry, arg, tmp.size) != 0) {
>  		ret = -EFAULT;
>  		goto free_newinfo;
>  	}

Something along this path seems to have broken with this patch. An
invocation of `iptables -A INPUT -m length --length 1360 -j DROP` now
fails, with

nf_setsockopt->do_replace->translate_table->check_entry_size_and_hooks:
  (unsigned char *)e + e->next_offset > limit  =>  TRUE

resulting in the whole call chain returning -EINVAL. It bisects back to
this commit. This is on net-next.

Jason
