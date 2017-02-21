From: Eric Dumazet <edumazet@google.com>
Date: Tue, 21 Feb 2017 13:53:13 +0000
Subject: Re: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Message-Id: <CANn89iJwGgyskr99Zp6HD7LPg7YfBtRWe4Br4GzV4g9UfN=sgQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20170221112740.661-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170221112740.661-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Feb 21, 2017 at 5:43 AM, Arnaldo Carvalho de Melo
<acme@kernel.org> wrote:
>
> Em Tue, Feb 21, 2017 at 02:27:40PM +0300, Andrey Ryabinin escreveu:
> > DCCP doesn't purge timewait sockets on network namespace shutdown.
> > So, after net namespace destroyed we could still have an active timer
> > which will trigger use after free in tw_timer_handler():
> >
> >
> > Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
> > timewait sockets on net namespace destruction and prevent above issue.
>
> Please add this, to help stable kernels to pick this up
>
> Fixes: b099ce2602d8 ("net: Batch inet_twsk_purge")
> Cc: Eric W. Biederman <ebiederm@xmission.com>


This patch has nothing to do with this bug really.

Look at commit d315492b1a6ba29da0fa2860759505ae1b2db857
("netns : fix kernel panic in timewait socket destruction")

Back in 2008, nobody spotted that DCCP was using the same infra.

When can we get rid of DCCP in linux so that syszkaller team no longer
spend time on it ?

Thanks.

>
> [acme@jouet linux]$ git describe b099ce2602d8
> v2.6.32-rc8-1977-gb099ce2602d8
>
> This one added the pernet operations related to network namespaces, but
> then the one above got missed.
>
> commit 72a2d6138224298a576bcdc33d7d0004de604856
> Author: Pavel Emelyanov <xemul@openvz.org>
> Date:   Sun Apr 13 22:29:13 2008 -0700
>
>     [NETNS][DCCPV4]: Add dummy per-net operations.
>
> ----------------------------------
>
> It looks ok, so please consider adding my:
>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>
> - Arnaldo
>
> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
> > Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > ---
> >  net/dccp/ipv4.c | 6 ++++++
> >  net/dccp/ipv6.c | 6 ++++++
> >  2 files changed, 12 insertions(+)
> >
> > diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> > index d859a5c..da7cb16 100644
> > --- a/net/dccp/ipv4.c
> > +++ b/net/dccp/ipv4.c
> > @@ -1018,9 +1018,15 @@ static void __net_exit dccp_v4_exit_net(struct net *net)
> >       inet_ctl_sock_destroy(net->dccp.v4_ctl_sk);
> >  }
> >
> > +static void __net_exit dccp_v4_exit_batch(struct list_head *net_exit_list)
> > +{
> > +     inet_twsk_purge(&dccp_hashinfo, &dccp_death_row, AF_INET);
> > +}
> > +
> >  static struct pernet_operations dccp_v4_ops = {
> >       .init   = dccp_v4_init_net,
> >       .exit   = dccp_v4_exit_net,
> > +     .exit_batch = dccp_v4_exit_batch,
> >  };
> >
> >  static int __init dccp_v4_init(void)
> > diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> > index c4e879c..f3d8f92 100644
> > --- a/net/dccp/ipv6.c
> > +++ b/net/dccp/ipv6.c
> > @@ -1077,9 +1077,15 @@ static void __net_exit dccp_v6_exit_net(struct net *net)
> >       inet_ctl_sock_destroy(net->dccp.v6_ctl_sk);
> >  }
> >
> > +static void __net_exit dccp_v6_exit_batch(struct list_head *net_exit_list)
> > +{
> > +     inet_twsk_purge(&dccp_hashinfo, &dccp_death_row, AF_INET6);
> > +}
> > +
> >  static struct pernet_operations dccp_v6_ops = {
> >       .init   = dccp_v6_init_net,
> >       .exit   = dccp_v6_exit_net,
> > +     .exit_batch = dccp_v6_exit_batch,
> >  };
> >
> >  static int __init dccp_v6_init(void)
> > --
> > 2.10.2
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe dccp" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
