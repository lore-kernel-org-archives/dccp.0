From: Joanne Koong <joannelkoong@gmail.com>
Date: Thu, 17 Nov 2022 21:32:18 +0000
Subject: Re: [PATCH v2 net 3/4] dccp/tcp: Don't update saddr before unlinking sk from the old bucket
Message-Id: <CAJnrk1Y=qBAYsJJRgL1_Vx8Cb+tvS9PKEiFpYXPmc1b3tFL2nQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20221116222805.64734-4-kuniyu@amazon.com>
In-Reply-To: <20221116222805.64734-4-kuniyu@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Nov 16, 2022 at 2:29 PM Kuniyuki Iwashima <kuniyu@amazon.com> wrote:
>
> Currently, we update saddr before calling inet_bhash2_update_saddr(), so
> another thread iterating over the bhash2 bucket might see an inconsistent
> address.
>
> Let's update saddr after unlinking sk from the old bhash2 bucket.

I'm not sure whether this patch is necessary and I'm curious to hear
your thoughts. There's no adverse effect that comes from updating the
sk's saddr before calling inet_bhash2_update_saddr() in the current
code. Another thread can be iterating over the bhash2 bucket, but it
has no effect whether they see this new address or not (eg when they
are iterating through the bucket they are trying to check for bind
conflicts on another socket, and the sk having the new address doesn't
affect this). What are your thoughts?

>
> Fixes: 28044fc1d495 ("net: Add a bhash2 table hashed by port and address")
> Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
> ---
>  include/net/inet_hashtables.h |  2 +-
>  net/dccp/ipv4.c               | 22 ++++------------------
>  net/dccp/ipv6.c               | 23 ++++-------------------
>  net/ipv4/af_inet.c            | 11 +----------
>  net/ipv4/inet_hashtables.c    | 31 ++++++++++++++++++++++++++++---
>  net/ipv4/tcp_ipv4.c           | 20 ++++----------------
>  net/ipv6/tcp_ipv6.c           | 19 +++----------------
>  7 files changed, 45 insertions(+), 83 deletions(-)
>
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index 3af1e927247d..ba06e8b52264 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -281,7 +281,7 @@ inet_bhash2_addr_any_hashbucket(const struct sock *sk, const struct net *net, in
>   * sk_v6_rcv_saddr (ipv6) changes after it has been binded. The socket's
>   * rcv_saddr field should already have been updated when this is called.
>   */
> -int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct sock *sk);
> +int inet_bhash2_update_saddr(struct sock *sk, void *saddr, int family);
>
>  void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
>                     struct inet_bind2_bucket *tb2, unsigned short port);
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 40640c26680e..95e376e3b911 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -45,11 +45,10 @@ static unsigned int dccp_v4_pernet_id __read_mostly;
>  int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  {
>         const struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
> -       struct inet_bind_hashbucket *prev_addr_hashbucket = NULL;
> -       __be32 daddr, nexthop, prev_sk_rcv_saddr;
>         struct inet_sock *inet = inet_sk(sk);
>         struct dccp_sock *dp = dccp_sk(sk);
>         __be16 orig_sport, orig_dport;
> +       __be32 daddr, nexthop;
>         struct flowi4 *fl4;
>         struct rtable *rt;
>         int err;
> @@ -91,26 +90,13 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>                 daddr = fl4->daddr;
>
>         if (inet->inet_saddr = 0) {
> -               if (inet_csk(sk)->icsk_bind2_hash) {
> -                       prev_addr_hashbucket > -                               inet_bhashfn_portaddr(&dccp_hashinfo, sk,
> -                                                     sock_net(sk),
> -                                                     inet->inet_num);
> -                       prev_sk_rcv_saddr = sk->sk_rcv_saddr;
> -               }
> -               inet->inet_saddr = fl4->saddr;
> -       }
> -
> -       sk_rcv_saddr_set(sk, inet->inet_saddr);
> -
> -       if (prev_addr_hashbucket) {
> -               err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
> +               err = inet_bhash2_update_saddr(sk,  &fl4->saddr, AF_INET);
>                 if (err) {
> -                       inet->inet_saddr = 0;
> -                       sk_rcv_saddr_set(sk, prev_sk_rcv_saddr);
>                         ip_rt_put(rt);
>                         return err;
>                 }
> +       } else {
> +               sk_rcv_saddr_set(sk, inet->inet_saddr);
>         }
>
>         inet->inet_dport = usin->sin_port;
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 626166cb6d7e..94c101ed57a9 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -934,26 +934,11 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
>         }
>
>         if (saddr = NULL) {
> -               struct inet_bind_hashbucket *prev_addr_hashbucket = NULL;
> -               struct in6_addr prev_v6_rcv_saddr;
> -
> -               if (icsk->icsk_bind2_hash) {
> -                       prev_addr_hashbucket = inet_bhashfn_portaddr(&dccp_hashinfo,
> -                                                                    sk, sock_net(sk),
> -                                                                    inet->inet_num);
> -                       prev_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
> -               }
> -
>                 saddr = &fl6.saddr;
> -               sk->sk_v6_rcv_saddr = *saddr;
> -
> -               if (prev_addr_hashbucket) {
> -                       err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
> -                       if (err) {
> -                               sk->sk_v6_rcv_saddr = prev_v6_rcv_saddr;
> -                               goto failure;
> -                       }
> -               }
> +
> +               err = inet_bhash2_update_saddr(sk, saddr, AF_INET6);
> +               if (err)
> +                       goto failure;
>         }
>
>         /* set the source address */
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 4728087c42a5..0da679411330 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1230,7 +1230,6 @@ EXPORT_SYMBOL(inet_unregister_protosw);
>
>  static int inet_sk_reselect_saddr(struct sock *sk)
>  {
> -       struct inet_bind_hashbucket *prev_addr_hashbucket;
>         struct inet_sock *inet = inet_sk(sk);
>         __be32 old_saddr = inet->inet_saddr;
>         __be32 daddr = inet->inet_daddr;
> @@ -1260,16 +1259,8 @@ static int inet_sk_reselect_saddr(struct sock *sk)
>                 return 0;
>         }
>
> -       prev_addr_hashbucket > -               inet_bhashfn_portaddr(tcp_or_dccp_get_hashinfo(sk), sk,
> -                                     sock_net(sk), inet->inet_num);
> -
> -       inet->inet_saddr = inet->inet_rcv_saddr = new_saddr;
> -
> -       err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
> +       err = inet_bhash2_update_saddr(sk, &new_saddr, AF_INET);
>         if (err) {
> -               inet->inet_saddr = old_saddr;
> -               inet->inet_rcv_saddr = old_saddr;
>                 ip_rt_put(rt);
>                 return err;
>         }
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index d745f962745e..dcb6bc918966 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -858,7 +858,20 @@ inet_bhash2_addr_any_hashbucket(const struct sock *sk, const struct net *net, in
>         return &hinfo->bhash2[hash & (hinfo->bhash_size - 1)];
>  }
>
> -int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct sock *sk)
> +static void inet_update_saddr(struct sock *sk, void *saddr, int family)
> +{
> +#if IS_ENABLED(CONFIG_IPV6)
> +       if (family = AF_INET6) {
> +               sk->sk_v6_rcv_saddr = *(struct in6_addr *)saddr;
> +       } else
> +#endif
> +       {
> +               inet_sk(sk)->inet_saddr = *(__be32 *)saddr;
> +               sk_rcv_saddr_set(sk, inet_sk(sk)->inet_saddr);
> +       }
> +}
> +
> +int inet_bhash2_update_saddr(struct sock *sk, void *saddr, int family)
>  {
>         struct inet_hashinfo *hinfo = tcp_or_dccp_get_hashinfo(sk);
>         struct inet_bind2_bucket *tb2, *new_tb2;
> @@ -867,6 +880,12 @@ int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct soc
>         int port = inet_sk(sk)->inet_num;
>         struct net *net = sock_net(sk);
>
> +       if (!inet_csk(sk)->icsk_bind2_hash) {
> +               /* Not bind()ed before. */
> +               inet_update_saddr(sk, saddr, family);
> +               return 0;
> +       }
> +
>         /* Allocate a bind2 bucket ahead of time to avoid permanently putting
>          * the bhash2 table in an inconsistent state if a new tb2 bucket
>          * allocation fails.
> @@ -875,12 +894,18 @@ int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct soc
>         if (!new_tb2)
>                 return -ENOMEM;
>
> +       /* Unlink first not to show the wrong address for other threads. */
>         head2 = inet_bhashfn_portaddr(hinfo, sk, net, port);
>
> -       spin_lock_bh(&prev_saddr->lock);
> +       spin_lock_bh(&head2->lock);
>         __sk_del_bind2_node(sk);
>         inet_bind2_bucket_destroy(hinfo->bind2_bucket_cachep, inet_csk(sk)->icsk_bind2_hash);
> -       spin_unlock_bh(&prev_saddr->lock);
> +       spin_unlock_bh(&head2->lock);
> +
> +       inet_update_saddr(sk, saddr, family);
> +
> +       /* Update bhash2 bucket. */
> +       head2 = inet_bhashfn_portaddr(hinfo, sk, net, port);
>
>         spin_lock_bh(&head2->lock);
>         tb2 = inet_bind2_bucket_find(head2, net, port, l3mdev, sk);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 6a3a732b584d..23dd7e9df2d5 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -199,15 +199,14 @@ static int tcp_v4_pre_connect(struct sock *sk, struct sockaddr *uaddr,
>  /* This will initiate an outgoing connection. */
>  int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  {
> -       struct inet_bind_hashbucket *prev_addr_hashbucket = NULL;
>         struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
>         struct inet_timewait_death_row *tcp_death_row;
> -       __be32 daddr, nexthop, prev_sk_rcv_saddr;
>         struct inet_sock *inet = inet_sk(sk);
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct ip_options_rcu *inet_opt;
>         struct net *net = sock_net(sk);
>         __be16 orig_sport, orig_dport;
> +       __be32 daddr, nexthop;
>         struct flowi4 *fl4;
>         struct rtable *rt;
>         int err;
> @@ -251,24 +250,13 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>         tcp_death_row = &sock_net(sk)->ipv4.tcp_death_row;
>
>         if (!inet->inet_saddr) {
> -               if (inet_csk(sk)->icsk_bind2_hash) {
> -                       prev_addr_hashbucket = inet_bhashfn_portaddr(tcp_death_row->hashinfo,
> -                                                                    sk, net, inet->inet_num);
> -                       prev_sk_rcv_saddr = sk->sk_rcv_saddr;
> -               }
> -               inet->inet_saddr = fl4->saddr;
> -       }
> -
> -       sk_rcv_saddr_set(sk, inet->inet_saddr);
> -
> -       if (prev_addr_hashbucket) {
> -               err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
> +               err = inet_bhash2_update_saddr(sk,  &fl4->saddr, AF_INET);
>                 if (err) {
> -                       inet->inet_saddr = 0;
> -                       sk_rcv_saddr_set(sk, prev_sk_rcv_saddr);
>                         ip_rt_put(rt);
>                         return err;
>                 }
> +       } else {
> +               sk_rcv_saddr_set(sk, inet->inet_saddr);
>         }
>
>         if (tp->rx_opt.ts_recent_stamp && inet->inet_daddr != daddr) {
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 81b396e5cf79..2f3ca3190d26 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -292,24 +292,11 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
>         tcp_death_row = &sock_net(sk)->ipv4.tcp_death_row;
>
>         if (!saddr) {
> -               struct inet_bind_hashbucket *prev_addr_hashbucket = NULL;
> -               struct in6_addr prev_v6_rcv_saddr;
> -
> -               if (icsk->icsk_bind2_hash) {
> -                       prev_addr_hashbucket = inet_bhashfn_portaddr(tcp_death_row->hashinfo,
> -                                                                    sk, net, inet->inet_num);
> -                       prev_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
> -               }
>                 saddr = &fl6.saddr;
> -               sk->sk_v6_rcv_saddr = *saddr;
>
> -               if (prev_addr_hashbucket) {
> -                       err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
> -                       if (err) {
> -                               sk->sk_v6_rcv_saddr = prev_v6_rcv_saddr;
> -                               goto failure;
> -                       }
> -               }
> +               err = inet_bhash2_update_saddr(sk, saddr, AF_INET6);
> +               if (err)
> +                       goto failure;
>         }
>
>         /* set the source address */
> --
> 2.30.2
>
