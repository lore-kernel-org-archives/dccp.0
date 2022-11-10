From: Kuniyuki Iwashima <kuniyu@amazon.com>
Date: Thu, 10 Nov 2022 20:34:32 +0000
Subject: Re: [PATCH v1 net] dccp/tcp: Reset saddr on failure after inet6?_hash_connect().
Message-Id: <20221110203432.97668-1-kuniyu@amazon.com>
List-Id: <dccp.vger.kernel.org>
References: <20221103172419.20977-1-kuniyu@amazon.com>
In-Reply-To: <20221103172419.20977-1-kuniyu@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From:   Joanne Koong <joannelkoong@gmail.com>
Date:   Thu, 10 Nov 2022 10:59:43 -0800
>  hOn Sun, Nov 6, 2022 at 5:15 PM Kuniyuki Iwashima <kuniyu@amazon.com> wrote:
> >
> > From:   Joanne Koong <joannelkoong@gmail.com>
> > Date:   Sun, 6 Nov 2022 11:18:44 -0800
> > > On Thu, Nov 3, 2022 at 10:24 AM Kuniyuki Iwashima <kuniyu@amazon.com> wrote:
> > > >
> > > > When connect() is called on a socket bound to the wildcard address,
> > > > we change the socket's saddr to a local address.  If the socket
> > > > fails to connect() to the destination, we have to reset the saddr.
> > > >
> > > > However, when an error occurs after inet_hash6?_connect() in
> > > > (dccp|tcp)_v[46]_conect(), we forget to reset saddr and leave
> > > > the socket bound to the address.
> > > >
> > > > From the user's point of view, whether saddr is reset or not varies
> > > > with errno.  Let's fix this inconsistent behaviour.
> > > >
> > > > Note that with this patch, the repro [0] will trigger the WARN_ON()
> > > > in inet_csk_get_port() again, but this patch is not buggy and rather
> > > > fixes a bug papering over the bhash2's bug [1] for which we need
> > > > another fix.
> > > >
> > > > For the record, the repro causes -EADDRNOTAVAIL in inet_hash6_connect()
> > > > by this sequence:
> > > >
> > > >   s1 = socket()
> > > >   s1.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
> > > >   s1.bind(('127.0.0.1', 10000))
> > > >   s1.sendto(b'hello', MSG_FASTOPEN, (('127.0.0.1', 10000)))
> > > >   # or s1.connect(('127.0.0.1', 10000))
> > > >
> > > >   s2 = socket()
> > > >   s2.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
> > > >   s2.bind(('0.0.0.0', 10000))
> > > >   s2.connect(('127.0.0.1', 10000))  # -EADDRNOTAVAIL
> > > >
> > > >   s2.listen(32)  # WARN_ON(inet_csk(sk)->icsk_bind2_hash != tb2);
> > > >
> > > > [0]: https://syzkaller.appspot.com/bug?extid5d756bbd1f8b5c8f09
> > > > [1]: https://lore.kernel.org/netdev/20221029001249.86337-1-kuniyu@amazon.com/
> > > >
> > > > Fixes: 3df80d9320bc ("[DCCP]: Introduce DCCPv6")
> > > > Fixes: 7c657876b63c ("[DCCP]: Initial implementation")
> > > > Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> > > > Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
> > > > ---
> > > >  net/dccp/ipv4.c     | 2 ++
> > > >  net/dccp/ipv6.c     | 2 ++
> > > >  net/ipv4/tcp_ipv4.c | 2 ++
> > > >  net/ipv6/tcp_ipv6.c | 2 ++
> > > >  4 files changed, 8 insertions(+)
> > > >
> > > > diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> > > > index 713b7b8dad7e..40640c26680e 100644
> > > > --- a/net/dccp/ipv4.c
> > > > +++ b/net/dccp/ipv4.c
> > > > @@ -157,6 +157,8 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
> > > >          * This unhashes the socket and releases the local port, if necessary.
> > > >          */
> > > >         dccp_set_state(sk, DCCP_CLOSED);
> > > > +       if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
> > > > +               inet_reset_saddr(sk);
> > > >         ip_rt_put(rt);
> > > >         sk->sk_route_caps = 0;
> > > >         inet->inet_dport = 0;
> > > > diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> > > > index e57b43006074..626166cb6d7e 100644
> > > > --- a/net/dccp/ipv6.c
> > > > +++ b/net/dccp/ipv6.c
> > > > @@ -985,6 +985,8 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
> > > >
> > > >  late_failure:
> > > >         dccp_set_state(sk, DCCP_CLOSED);
> > > > +       if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
> > > > +               inet_reset_saddr(sk);
> > > >         __sk_dst_reset(sk);
> > > >  failure:
> > > >         inet->inet_dport = 0;
> > > > diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > > > index 87d440f47a70..6a3a732b584d 100644
> > > > --- a/net/ipv4/tcp_ipv4.c
> > > > +++ b/net/ipv4/tcp_ipv4.c
> > > > @@ -343,6 +343,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
> > > >          * if necessary.
> > > >          */
> > > >         tcp_set_state(sk, TCP_CLOSE);
> > > > +       if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
> > > > +               inet_reset_saddr(sk);
> > > >         ip_rt_put(rt);
> > > >         sk->sk_route_caps = 0;
> > > >         inet->inet_dport = 0;
> > > > diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> > > > index 2a3f9296df1e..81b396e5cf79 100644
> > > > --- a/net/ipv6/tcp_ipv6.c
> > > > +++ b/net/ipv6/tcp_ipv6.c
> > > > @@ -359,6 +359,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
> > > >
> > > >  late_failure:
> > > >         tcp_set_state(sk, TCP_CLOSE);
> > > > +       if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
> > > > +               inet_reset_saddr(sk);
> > > >  failure:
> > > >         inet->inet_dport = 0;
> > > >         sk->sk_route_caps = 0;
> > > > --
> > > > 2.30.2
> > > >
> > >
> > > inet_reset_saddr() sets both inet_saddr and inet_rcv_saddr to 0, but I
> > > think there are some edge cases where when dccp/tcp_v4/6_connect() is
> > > called, inet_saddr is 0 but inet_rcv_saddr is not, which means we'd
> > > need to reset inet_rcv_saddr to its original value. The example case
> > > I'm looking at is  __inet_bind() where if the request is to bind to a
> > > multicast address,
> > >
> > >     inet->inet_rcv_saddr = inet->inet_saddr = addr->sin_addr.s_addr;
> > >     if (chk_addr_ret = RTN_MULTICAST || chk_addr_ret = RTN_BROADCAST)
> > >         inet->inet_saddr = 0;  /* Use device */
> >
> > Thanks for reviewing.
> >
> > We have to take care of these two error paths.
> >
> >   * (dccp|tcp)_v[46]_coonnect()
> >   * __inet_stream_connect()
> >
> > In __inet_stream_connect(), we call ->disconnect(), which already has the
> > same logic in this patch.
> >
> > In your edge case, once (dccp|tcp)_v[46]_coonnect() succeeds, both of
> > inet->inet_saddr and sk_rcv_saddr are non-zero.  If connect() fails after
> > that, in ->disconnect(), we cannot know if we should restore sk_rcv_saddr
> > only.  Also, we don't have the previous address there.
> >
> > For these reasons, we reset both addresses only if the sk was bound to
> > INADDR_ANY, which we can detect by the SOCK_BINDADDR_LOCK flag.
> >
> > As you mentinoed, we can restore sk_rcv_saddr for the edge case in
> > (dccp|tcp)_v[46]_coonnect() but cannot in __inet_stream_connect().
> >
> > If we do so, we need another flag for the case and another member to save
> > the old multicast/broadcast address. (+ where we need rehash for bhash2)
> >
> > What do you think ?
> 
> Sorry for the late reply Kuniyuki, I didn't see your email in my inbox
> until Paolo resurfaced it.
> 
> I think this error case (eg multicast address) will be very rare +
> have minimal side-effects, and isn't worth accounting for in
> __inet_stream_connect().

Agreed.


> In (dccp|tcp)_v[46]_coonnect(), it seems
> simple to address because we already track the previous sk address in
> the "prev_sk_rcv_saddr" variable.
> 
> ALso, as a side-note, I think we'll need an additional patch to fix an
> existing bug that's related to resetting saddrs, where we'll need to
> first check whether there's a bind conflict in the bhash/bhash2 table
> before we can reset its saddr back to 0
> (https://lore.kernel.org/netdev/CAJnrk1Z1UFmJ2_-7G6sdNHYy0jfjbJjWiCmAzqtLN9dkJ_g+vA@mail.gmail.com/
> has some more info). I don't think that issue blocks this patch
> though.

For better issue overview, I'll repost this patch with another patch
to fix bhash2 bucket when resetting saddr.  After that, let's fix
another issue for checking conflict before resetting sk_rcv_saddr.
