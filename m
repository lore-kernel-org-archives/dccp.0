From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 23 Jan 2006 23:56:40 +0000
Subject: Re: Bug?? out of memory on receive for DCCP
Message-Id: <39e6f6c70601231556y7d2548cu251a6086d02df49a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0601231514g4d53131dl47bbaafb2997d110@mail.gmail.com>
In-Reply-To: <cbec11ac0601231514g4d53131dl47bbaafb2997d110@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/23/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> When I have been doing some stress testing on DCCP for my transmit
> changes using ttcp with a million packets I'm getting page allocation
> failures etc on the receive side (in code I haven't changed). I can
> also see memory going up dramatically when viewing through "top"
>
> Setup is two PCs on a LAN. I'm presuming this is because we don't put
> limit on receive buffers at present and ttcp is not pulling packets
> fast enough off buffers to stop memory exhausation.
>
> Is that correct?

Yes, this is possible, check the ccid3 packet history allocator, it
doesn't accounts the packet to the socket, try adding some basic upper
bound on the number of packets on a variable in the dccp_sock struct,
doing it in a similar way as TCP (memory moderation, etc) is in the
todo list.

- Arnaldo
