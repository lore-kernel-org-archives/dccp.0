From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:31:39 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <39e6f6c70704121431g7fbe9f2bj34a352a0f1d490c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/12/07, David Miller <davem@davemloft.net> wrote:
> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Date: Thu, 12 Apr 2007 18:14:54 -0300
>
> >  This patch replaces calls to do_gettimeofday at the receiver CCID 3
> >  with skb timestamps. The skb timestamps are computed earlier in the
> >  receive path, experimental measurements have shown that up to several
> >  hundred microseconds can lie between the skb receive timestamp and the
> >  timestamp taken when CCID 3 receives the packet. This difference has
> >  a negative impact on RTT estimation (reduced accuracy).
> >
> > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> > Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> > Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
>
> And this creates an even deeper dependency on the global packet
> timestamping facility.  Those are supposed to be enabled only
> in obscure circumstances because timestamping every packet is
> incredibly expensive.
>
> Please find a better way.

Well, there seems to be just one better way, to timestamp the packet
as soon as it enters the dccp stack, in dccp_v[46]_rcv, and consider
the time from the driver -> ip v[46] -> dccp_v[46]_ as "in the wire".

- Arnaldo
