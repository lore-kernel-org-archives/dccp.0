From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Aug 2020 22:21:25 +0000
Subject: Re: [PATCH 25/26] net: pass a sockptr_t into ->setsockopt
Message-Id: <6357942b-0b6e-1901-7dce-e308c9fac347@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-26-hch@lst.de>
In-Reply-To: <20200723060908.50081-26-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On 7/22/20 11:09 PM, Christoph Hellwig wrote:
> Rework the remaining setsockopt code to pass a sockptr_t instead of a
> plain user pointer.  This removes the last remaining set_fs(KERNEL_DS)
> outside of architecture specific code.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Stefan Schmidt <stefan@datenfreihafen.org> [ieee802154]
> ---


...

> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index 594e01ad670aa6..874f01cd7aec42 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -972,13 +972,13 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>  }
>  

...

>  static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
> -			    char __user *optval, unsigned int optlen)
> +			       sockptr_t optval, unsigned int optlen)
>  {
>  	struct raw6_sock *rp = raw6_sk(sk);
>  	int val;
>  
> -	if (get_user(val, (int __user *)optval))
> +	if (copy_from_sockptr(&val, optval, sizeof(val)))
>  		return -EFAULT;
>  

converting get_user(...)   to  copy_from_sockptr(...) really assumed the optlen
has been validated to be >= sizeof(int) earlier.

Which is not always the case, for example here.

User application can fool us passing optlen=0, and a user pointer of exactly TASK_SIZE-1

