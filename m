From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 03 Jan 2008 01:02:19 +0000
Subject: Re: dccp send
Message-Id: <20080103010219.GA29523@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Wed, Jan 02, 2008 at 11:34:25PM +0100, Tomasz Grobelny escreveu:
> Dnia Wednesday 02 of January 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> > Em Wed, Jan 02, 2008 at 01:41:16AM +0100, Tomasz Grobelny escreveu:
> > > When I use dccp does sendmsg function block (until it sends the packe=
t)?
> > > If so, should it? In either case, how to make it just queue the packet
> > > and return?
> >
> > The interface is the same as for other AF_INET transports, use
> > O_NONBLOCK (open, fcntl) if you want it to be non blocking.
> >
> But what are the semantics? In TCP if sendmsg blocks the application has =
no=20
> choice but to wait. The time for which sendmsg blocks it tightly connecte=
d=20

In DCCP its exactly the same semantic, sendmsg may block waiting for
send buffer space. If you don't want that use O_NONBLOCK and it will
return right away with EAGAIN.

> with speed at which packets can be transmitted over the network. Is it th=
e=20
> case for dccp as well? If so, does it mean that provided stable network=20
> conditions over longer period of time and using blocking version of sendm=
sg=20
> in a loop very few packets should be lost? (By very few I mean < 10%)

If the application sends many packets in rapid succession before the
DCCP core gets permission from the CCID in use to send those packets to
the network what will happen is that sk_write_queue will have packets
waiting, using the memory allowed to be allocated for the socket send
buffer, which will make sock_alloc_send_skb wait for the packets in
sk_write_queue to be sent, freeing up send buffer space, when it will be
possible for sock_alloc_send_skb to actually allocate memory for the
packet and return to dccp_sendmsg, that in turn will return to the
application after putting the newly allocated packet in sk_write_queue,
doing the send buffer accounting and trying to send something in
dccp_write_xmit, where it will ask the CCID if it can send some more
packets, got it?

Look at these sequences:

      sock_alloc_send_skb -> skb_set_owner_w

      This will set the skb destructor to be sock_wfree

Now look at what happens when the NIC driver finally frees the sk_buff
(the network packet):

      kfree_skb -> __kfree_skb -> skb_release_all -> skb->destructor (sock_=
wfree)

sock_wfree, in turn, will call sk->sk_write_space, that for DCCP is
dccp_write_space (see inet_create -> sk->sk_prot->init
(dccp_v4_init_sock) -> dccp_init_sock), that will wake up any tasks that
are sleeping in sk_sleep, that is... the process doing the dccp_sendmsg
-> sock_alloc_send_skb.

All this behaviour can be controlled thru O_NONBLOCK _and_
setsockopt(SO_SNDTIMEO), just like TCP.
=20
> > It queues it in the write routine and tries to send it right away, but
> > doesn't waits for actually sending the packet, i.e. it only checks if
> > there is write space available, if you set O_NONBLOCK and there is no
> > space it returns ENOBUFS, if O_NONBLOCK is not set it will sleep waiting
> > for write space to be made available, when the process will be awaken.

> dccp_sendmsg seems to block on call to sock_alloc_send_skb. Which at firs=
t=20
> look does not seems to send anything anywhere. So why does it block at al=
l?=20
> Can't it just allocate the data needed and return?

See above.

- Arnaldo
