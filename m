From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 03 Jan 2008 23:27:53 +0000
Subject: Re: dccp send
Message-Id: <20080103232753.GN29523@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Jan 04, 2008 at 11:25:29AM +1300, Ian McDonald escreveu:
> On Jan 4, 2008 11:19 AM, Tomasz Grobelny <tomasz@grobelny.oswiecenia.net> wrote:
> > I think I almost got it. Thanks a lot for the detailed explanation. But I've
> > got two more questions:
> > 1. How can I control the amount of "memory allowed to be allocated for the
> > socket send buffer"? It it somehow connected with tx_qlen or is it not?
> 
> I wrote the code here so let me comment - there is no fixed amount of
> memory allocated - it is determined by the tx_qlen. I was looking at

there is no memory allocated in advance nor explicit, DCCP specific
mechanism for limiting the amount of memory a socket can use for its
write queue, but DCCP uses sock_alloc_send_skb and that function does
memory accounting and checks if the maximum memory (SO_SNDBUF) has been
reached, when it makes the app to sleep if O_NONBLOCK is not set.

> implementing memory limits but it got too hard and as DCCP doesn't
> combine packets I thought it made it much simpler just to put a limit
> by packets.
> 
> > 2. If I decide that for whatever reason a given skb already in sk_write_queue
> > should not be transmitted I should remove it from queue and call kfree_skb on
> > it, it that right?
> 
> Correct. Remember of course all your locking mechanisms. If you want a
> good example look at the below towards the end:
> http://wand.net.nz/~iam4/dccp/patches20/30-best_packet_next.diff
> 
> (NB this patch applies against 2.6.20 after previous patches in series).

Correct if he is in-kernel.

- Arnaldo
