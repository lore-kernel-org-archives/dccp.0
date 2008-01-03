From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 03 Jan 2008 22:19:32 +0000
Subject: Re: dccp send
Message-Id: <200801032319.32197.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Thursday 03 January 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> Em Wed, Jan 02, 2008 at 11:34:25PM +0100, Tomasz Grobelny escreveu:
> > with speed at which packets can be transmitted over the network. Is it
> > the case for dccp as well? If so, does it mean that provided stable
> > network conditions over longer period of time and using blocking version
> > of sendmsg in a loop very few packets should be lost? (By very few I me=
an
> > < 10%)
>
> If the application sends many packets in rapid succession before the
> DCCP core gets permission from the CCID in use to send those packets to
> the network what will happen is that sk_write_queue will have packets
> waiting, using the memory allowed to be allocated for the socket send
> buffer, which will make sock_alloc_send_skb wait for the packets in
> sk_write_queue to be sent, freeing up send buffer space, when it will be
> possible for sock_alloc_send_skb to actually allocate memory for the
> packet and return to dccp_sendmsg, that in turn will return to the
> application after putting the newly allocated packet in sk_write_queue,
> doing the send buffer accounting and trying to send something in
> dccp_write_xmit, where it will ask the CCID if it can send some more
> packets, got it?
>
I think I almost got it. Thanks a lot for the detailed explanation. But I'v=
e=20
got two more questions:
1. How can I control the amount of "memory allowed to be allocated for the =

socket send buffer"? It it somehow connected with tx_qlen or is it not?
2. If I decide that for whatever reason a given skb already in sk_write_que=
ue=20
should not be transmitted I should remove it from queue and call kfree_skb =
on=20
it, it that right?
--=20
Regards,
Tomasz Grobelny
