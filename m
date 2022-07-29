From: Jakub Kicinski <kuba@kernel.org>
Date: Fri, 29 Jul 2022 02:59:38 +0000
Subject: Re: [PATCH] dccp: put dccp_qpolicy_full() and dccp_qpolicy_push() in the same lock
Message-Id: <20220728200139.1e7d9bc6@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20220727080609.26532-1-hbh25y@gmail.com>
In-Reply-To: <20220727080609.26532-1-hbh25y@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, 27 Jul 2022 16:06:09 +0800 Hangyu Hua wrote:
> In the case of sk->dccps_qpolicy = DCCPQ_POLICY_PRIO, dccp_qpolicy_full
> will drop a skb when qpolicy is full. And the lock in dccp_sendmsg is
> released before sock_alloc_send_skb and then relocked after
> sock_alloc_send_skb. The following conditions may lead dccp_qpolicy_push
> to add skb to an already full sk_write_queue:
> 
> thread1--->lock
> thread1--->dccp_qpolicy_full: queue is full. drop a skb

This linie should say "not full"?

> thread1--->unlock
> thread2--->lock
> thread2--->dccp_qpolicy_full: queue is not full. no need to drop.
> thread2--->unlock
> thread1--->lock
> thread1--->dccp_qpolicy_push: add a skb. queue is full.
> thread1--->unlock
> thread2--->lock
> thread2--->dccp_qpolicy_push: add a skb!
> thread2--->unlock
> 
> Fix this by moving dccp_qpolicy_full.
> 
> Fixes: 871a2c16c21b ("dccp: Policy-based packet dequeueing infrastructure")

This code was added in b1308dc015eb0, AFAICT. Please double check.

> Signed-off-by: Hangyu Hua <hbh25y@gmail.com>
> ---
>  net/dccp/proto.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
> index eb8e128e43e8..1a0193823c82 100644
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -736,11 +736,6 @@ int dccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>  
>  	lock_sock(sk);
>  
> -	if (dccp_qpolicy_full(sk)) {
> -		rc = -EAGAIN;
> -		goto out_release;
> -	}
> -
>  	timeo = sock_sndtimeo(sk, noblock);
>  
>  	/*
> @@ -773,6 +768,11 @@ int dccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>  	if (rc != 0)
>  		goto out_discard;
>  
> +	if (dccp_qpolicy_full(sk)) {
> +		rc = -EAGAIN;
> +		goto out_discard;
> +	}

Shouldn't this be earlier, right after relocking? Why copy the data etc.
if we know the queue is full?

>  	dccp_qpolicy_push(sk, skb);
>  	/*
>  	 * The xmit_timer is set if the TX CCID is rate-based and will expire
