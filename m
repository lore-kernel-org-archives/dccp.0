From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 03 Jan 2008 23:23:48 +0000
Subject: Re: dccp send
Message-Id: <20080103232348.GM29523@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Thu, Jan 03, 2008 at 11:19:32PM +0100, Tomasz Grobelny escreveu:
> Dnia Thursday 03 January 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> > Em Wed, Jan 02, 2008 at 11:34:25PM +0100, Tomasz Grobelny escreveu:
> > > with speed at which packets can be transmitted over the network. Is it
> > > the case for dccp as well? If so, does it mean that provided stable
> > > network conditions over longer period of time and using blocking vers=
ion
> > > of sendmsg in a loop very few packets should be lost? (By very few I =
mean
> > > < 10%)
> >
> > If the application sends many packets in rapid succession before the
> > DCCP core gets permission from the CCID in use to send those packets to
> > the network what will happen is that sk_write_queue will have packets
> > waiting, using the memory allowed to be allocated for the socket send
> > buffer, which will make sock_alloc_send_skb wait for the packets in
> > sk_write_queue to be sent, freeing up send buffer space, when it will be
> > possible for sock_alloc_send_skb to actually allocate memory for the
> > packet and return to dccp_sendmsg, that in turn will return to the
> > application after putting the newly allocated packet in sk_write_queue,
> > doing the send buffer accounting and trying to send something in
> > dccp_write_xmit, where it will ask the CCID if it can send some more
> > packets, got it?
> >
> I think I almost got it. Thanks a lot for the detailed explanation. But I=
've=20
> got two more questions:
> 1. How can I control the amount of "memory allowed to be allocated for th=
e=20
> socket send buffer"? It it somehow connected with tx_qlen or is it not?

setsockopt(socket_descriptor, SOL_SOCKET, SO_SNDBUF,  ...)

execute:

man 7 socket
/SO_SNDBUF

tx_qlen is something experimental, system wide.

> 2. If I decide that for whatever reason a given skb already in sk_write_q=
ueue=20
> should not be transmitted I should remove it from queue and call kfree_sk=
b on=20
> it, it that right?

There is no interface for that right now, once you pass a packet to the
kernel, the application has no control over it anymore. But there has
been talks about things like setting a timeout for packets to stay on
the queue, or even for the app to have an interface for dropping packets
from the head of the queue.

- Arnaldo
