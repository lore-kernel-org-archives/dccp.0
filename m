From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 02 Jan 2008 22:34:25 +0000
Subject: Re: dccp send
Message-Id: <200801022334.25847.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 02 of January 2008, Arnaldo Carvalho de Melo napisa=B3:
> Em Wed, Jan 02, 2008 at 01:41:16AM +0100, Tomasz Grobelny escreveu:
> > When I use dccp does sendmsg function block (until it sends the packet)?
> > If so, should it? In either case, how to make it just queue the packet
> > and return?
>
> The interface is the same as for other AF_INET transports, use
> O_NONBLOCK (open, fcntl) if you want it to be non blocking.
>
But what are the semantics? In TCP if sendmsg blocks the application has no=
=20
choice but to wait. The time for which sendmsg blocks it tightly connected =

with speed at which packets can be transmitted over the network. Is it the =

case for dccp as well? If so, does it mean that provided stable network=20
conditions over longer period of time and using blocking version of sendmsg=
=20
in a loop very few packets should be lost? (By very few I mean < 10%)

> It queues it in the write routine and tries to send it right away, but
> doesn't waits for actually sending the packet, i.e. it only checks if
> there is write space available, if you set O_NONBLOCK and there is no
> space it returns ENOBUFS, if O_NONBLOCK is not set it will sleep waiting
> for write space to be made available, when the process will be awaken.
>
dccp_sendmsg seems to block on call to sock_alloc_send_skb. Which at first =

look does not seems to send anything anywhere. So why does it block at all?=
=20
Can't it just allocate the data needed and return?
--=20
Regards,
Tomasz Grobelny
