From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 25 Feb 2006 22:32:47 +0000
Subject: Re: [PATCH] [ICSK]: Introduce inet_csk_ctl_sock_create
Message-Id: <39e6f6c70602251432y1d8236edtde80704ca0e4f5d1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <11409064891373-git-send-email-acme@mandriva.com>
In-Reply-To: <11409064891373-git-send-email-acme@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

  I should have used git-send-email --compose even with just one cset, ah
and include netdev too, sorry.

    Now there are 4 outstanding changesets in this tree.

Regards,

- Arnaldo

On 2/25/06, Arnaldo Carvalho de Melo <acme@mandriva.com> wrote:
> Consolidating open coded sequences in tcp and dccp, v4 and v6.
>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
>
> ---
>
>  include/net/inet_connection_sock.h |    4 ++++
>  net/dccp/ipv4.c                    |   26 ++------------------------
>  net/dccp/ipv6.c                    |   27 +++------------------------
>  net/ipv4/inet_connection_sock.c    |   19 +++++++++++++++++++
>  net/ipv4/tcp_ipv4.c                |   13 +------------
>  net/ipv6/tcp_ipv6.c                |   13 ++-----------
>  6 files changed, 31 insertions(+), 71 deletions(-)
>
> d2c5bf98ebbf4ad6ab670ec0e65494b04e75ab90
> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> index c0a4d3c..3895420 100644
> --- a/include/net/inet_connection_sock.h
> +++ b/include/net/inet_connection_sock.h
> @@ -321,4 +321,8 @@ extern void inet_csk_listen_stop(struct
>
>  extern void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
>
> +extern int inet_csk_ctl_sock_create(struct socket **sock,
> +                                   unsigned short family,
> +                                   unsigned short type,
> +                                   unsigned char protocol);
>  #endif /* _INET_CONNECTION_SOCK_H */
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index f53bce5..7098f10 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -1099,29 +1099,6 @@ static struct inet_protosw dccp_v4_proto
>         .flags          = INET_PROTOSW_ICSK,
>  };
>
> -static char dccp_v4_ctl_socket_err_msg[] __initdata > -       KERN_ERR "DCCP: Failed to create the control socket.\n";
> -
> -static int __init dccp_v4_ctl_sock_init(void)
> -{
> -       int rc = sock_create_kern(PF_INET, SOCK_DCCP, IPPROTO_DCCP,
> -                                 &dccp_v4_ctl_socket);
> -       if (rc < 0)
> -               printk(dccp_v4_ctl_socket_err_msg);
> -       else {
> -               dccp_v4_ctl_socket->sk->sk_allocation = GFP_ATOMIC;
> -               inet_sk(dccp_v4_ctl_socket->sk)->uc_ttl = -1;
> -
> -               /* Unhash it so that IP input processing does not even
> -                * see it, we do not wish this socket to see incoming
> -                * packets.
> -                */
> -               dccp_v4_ctl_socket->sk->sk_prot->unhash(dccp_v4_ctl_socket->sk);
> -       }
> -
> -       return rc;
> -}
> -
>  static int __init dccp_v4_init(void)
>  {
>         int err = proto_register(&dccp_v4_prot, 1);
> @@ -1135,7 +1112,8 @@ static int __init dccp_v4_init(void)
>
>         inet_register_protosw(&dccp_v4_protosw);
>
> -       err = dccp_v4_ctl_sock_init();
> +       err = inet_csk_ctl_sock_create(&dccp_v4_ctl_socket, PF_INET,
> +                                      SOCK_DCCP, IPPROTO_DCCP);
>         if (err)
>                 goto out_unregister_protosw;
>  out:
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 3c9f083..6bd9979 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -1229,29 +1229,6 @@ static struct inet_protosw dccp_v6_proto
>         .flags          = INET_PROTOSW_ICSK,
>  };
>
> -static char dccp_v6_ctl_socket_err_msg[] __initdata > -       KERN_ERR "DCCP: Failed to create the control socket.\n";
> -
> -static int __init dccp_v6_ctl_sock_init(void)
> -{
> -       int rc = sock_create_kern(PF_INET6, SOCK_DCCP, IPPROTO_DCCP,
> -                                 &dccp_v6_ctl_socket);
> -       if (rc < 0)
> -               printk(dccp_v6_ctl_socket_err_msg);
> -       else {
> -               dccp_v6_ctl_socket->sk->sk_allocation = GFP_ATOMIC;
> -               inet_sk(dccp_v6_ctl_socket->sk)->uc_ttl = -1;
> -
> -               /* Unhash it so that IP input processing does not even
> -                * see it, we do not wish this socket to see incoming
> -                * packets.
> -                */
> -               dccp_v6_ctl_socket->sk->sk_prot->unhash(dccp_v6_ctl_socket->sk);
> -       }
> -
> -       return rc;
> -}
> -
>  static int __init dccp_v6_init(void)
>  {
>         int err = proto_register(&dccp_v6_prot, 1);
> @@ -1265,7 +1242,9 @@ static int __init dccp_v6_init(void)
>
>         inet6_register_protosw(&dccp_v6_protosw);
>
> -       if (dccp_v6_ctl_sock_init() != 0)
> +       err = inet_csk_ctl_sock_create(&dccp_v6_ctl_socket, PF_INET6,
> +                                      SOCK_DCCP, IPPROTO_DCCP);
> +       if (err != 0)
>                 goto out_unregister_protosw;
>  out:
>         return err;
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index ae20281..359f48c 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -648,3 +648,22 @@ void inet_csk_addr2sockaddr(struct sock
>  }
>
>  EXPORT_SYMBOL_GPL(inet_csk_addr2sockaddr);
> +
> +int inet_csk_ctl_sock_create(struct socket **sock, unsigned short family,
> +                            unsigned short type, unsigned char protocol)
> +{
> +       int rc = sock_create_kern(family, type, protocol, sock);
> +
> +       if (rc = 0) {
> +               (*sock)->sk->sk_allocation = GFP_ATOMIC;
> +               inet_sk((*sock)->sk)->uc_ttl = -1;
> +               /*
> +                * Unhash it so that IP input processing does not even see it,
> +                * we do not wish this socket to see incoming packets.
> +                */
> +               (*sock)->sk->sk_prot->unhash((*sock)->sk);
> +       }
> +       return rc;
> +}
> +
> +EXPORT_SYMBOL_GPL(inet_csk_ctl_sock_create);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 57e7a26..4eb903d 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1828,21 +1828,10 @@ struct proto tcp_prot = {
>         .rsk_prot               = &tcp_request_sock_ops,
>  };
>
> -
> -
>  void __init tcp_v4_init(struct net_proto_family *ops)
>  {
> -       int err = sock_create_kern(PF_INET, SOCK_RAW, IPPROTO_TCP, &tcp_socket);
> -       if (err < 0)
> +       if (inet_csk_ctl_sock_create(&tcp_socket, PF_INET, SOCK_RAW, IPPROTO_TCP) < 0)
>                 panic("Failed to create the TCP control socket.\n");
> -       tcp_socket->sk->sk_allocation   = GFP_ATOMIC;
> -       inet_sk(tcp_socket->sk)->uc_ttl = -1;
> -
> -       /* Unhash it so that IP input processing does not even
> -        * see it, we do not wish this socket to see incoming
> -        * packets.
> -        */
> -       tcp_socket->sk->sk_prot->unhash(tcp_socket->sk);
>  }
>
>  EXPORT_SYMBOL(ipv4_specific);
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 14de503..af6a0c6 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1605,21 +1605,12 @@ static struct inet_protosw tcpv6_protosw
>
>  void __init tcpv6_init(void)
>  {
> -       int err;
> -
>         /* register inet6 protocol */
>         if (inet6_add_protocol(&tcpv6_protocol, IPPROTO_TCP) < 0)
>                 printk(KERN_ERR "tcpv6_init: Could not register protocol\n");
>         inet6_register_protosw(&tcpv6_protosw);
>
> -       err = sock_create_kern(PF_INET6, SOCK_RAW, IPPROTO_TCP, &tcp6_socket);
> -       if (err < 0)
> +       if (inet_csk_ctl_sock_create(&tcp6_socket, PF_INET6, SOCK_RAW,
> +                                    IPPROTO_TCP) < 0)
>                 panic("Failed to create the TCPv6 control socket.\n");
> -       tcp6_socket->sk->sk_allocation = GFP_ATOMIC;
> -
> -       /* Unhash it so that IP input processing does not even
> -        * see it, we do not wish this socket to see incoming
> -        * packets.
> -        */
> -       tcp6_socket->sk->sk_prot->unhash(tcp6_socket->sk);
>  }
> --
> 1.2.2.gd27d
