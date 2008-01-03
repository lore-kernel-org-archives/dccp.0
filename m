From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 03 Jan 2008 22:25:29 +0000
Subject: Re: dccp send
Message-Id: <5640c7e00801031425n6822fbeeo8735410974f616bd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Jan 4, 2008 11:19 AM, Tomasz Grobelny <tomasz@grobelny.oswiecenia.net> wrote:
> I think I almost got it. Thanks a lot for the detailed explanation. But I've
> got two more questions:
> 1. How can I control the amount of "memory allowed to be allocated for the
> socket send buffer"? It it somehow connected with tx_qlen or is it not?

I wrote the code here so let me comment - there is no fixed amount of
memory allocated - it is determined by the tx_qlen. I was looking at
implementing memory limits but it got too hard and as DCCP doesn't
combine packets I thought it made it much simpler just to put a limit
by packets.

> 2. If I decide that for whatever reason a given skb already in sk_write_queue
> should not be transmitted I should remove it from queue and call kfree_skb on
> it, it that right?

Correct. Remember of course all your locking mechanisms. If you want a
good example look at the below towards the end:
http://wand.net.nz/~iam4/dccp/patches20/30-best_packet_next.diff

(NB this patch applies against 2.6.20 after previous patches in series).

Regards,

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
