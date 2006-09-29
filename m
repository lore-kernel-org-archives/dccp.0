From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 29 Sep 2006 14:40:43 +0000
Subject: Re: [PATCH] IPv6/DCCP: Remove unused IPV6_PKTOPTIONS code
Message-Id: <39e6f6c70609290740s79bf0b1cwe0b64eef8074eeeb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200609291102.19243@strip-the-willow>
In-Reply-To: <200609291102.19243@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> >  Coverity found what looks like a real leak in net/dccp/ipv6.c::dccp_v6_do_rcv()
>
> |  otoh, it seems to me that opt_skb doesn't actually do anything and can be
> |  removed?
> This is right, there is no code referencing opt_skb: compare with net/ipv6/tcp_ipv6.c.
> Until someone has time to add the missing DCCP-specific code, it does seem better
> to replace the dead part with a FIXME. This is done by the patch below, applies to
> davem-net2.6 and has been tested to compile.

Thanks, I've been again sidetracked by Real Life(tm) but hopefully
tomorrow I'll go over all the DCCP pending patches backlog and get
them into tree to submit to Dave.

- Arnaldo
