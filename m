From: David Miller <davem@davemloft.net>
Date: Tue, 22 Apr 2008 22:42:12 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080422.154212.108914213.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Apr 2008 18:41:52 +0100

> | If we iron this out we could finally return to the main subject of this 
> | thread. That is Patch v2 by me and Gerrit...
> | -- 
> Fully agree - we just need to decide whether or not to use skb->priority.
> 
> Below is as far as I got in integrating your patch last week, it shows
> only the major changes. The following bits have been updated:
> 
>  * skb->priority now cleared before passing the skb onto layer 3;
>  * order of statements in prio_push() reversed (first dropping worst
>    skb and then pushing the new skb - this is better when e.g.
>    tx_qlen=1);
>  * added general parsing routine for cmsg(3) socket control messages
>    and defined one for the SOL_DCCP socket level; thanks to advice
>    by Dave Miller

If this usage of skb->priority is going to override the
IP_TOS socket option setting, I don't think it's a good
idea.

Right now every packet output goes through ip_output.c
which sets skb->priority to sk->sk_priority, which is set
by the user via the IP_TOS socket option in ip_sockglue.c
