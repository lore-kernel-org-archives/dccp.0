From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 04 Jun 2008 16:54:24 +0000
Subject: Re: [PATCH - test-tree] DCCP: Increment sequence number on
Message-Id: <20080604165424.GE4625@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <4846462F.3020004@cn.fujitsu.com>
In-Reply-To: <4846462F.3020004@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Jun 04, 2008 at 04:55:40PM +0100, Gerrit Renker escreveu:
> | But why do you have to? If it is a REQUEST, don't bump the GSS... wait,
> | I actually took the time and went to re-read the RFC and I think the
> | changelog Wei wrote is misleading, as:
> | 
> | -------------------- 8< ------------------------------------------------
> |    A client in the REQUEST state SHOULD use an exponential-backoff timer
> |    to send new DCCP-Request packets if no response is received.  The
> |    first retransmission should occur after approximately one second,
> |    backing off to not less than one packet every 64 seconds; or the
> |    endpoint can use whatever retransmission strategy is followed for
> |    retransmitting TCP SYNs.  Each new DCCP-Request MUST increment the
> |    Sequence Number by one and MUST contain the same Service Code and
> |    application data as the original DCCP-Request.
> | -------------------- 8< ------------------------------------------------
> | 
> | So the fix would be for not bumping GSS on the first packet? I guess so,
> | the flow is:
> | 
> | To create a socket:
> | 
> |  dccp_v4_connect(): sets iss
> |    dccp_connect()
> |      dccp_connect_init(): iss = gss
> |      dccp_transmit_skb: gss += 1
> | 
> | So the problem is that if this is the first packet being sent on a
> | connection we should not do the gss += 1...
> | 
> Yes exactly that is the problem. And I find it ugly, too, to first set
> ISS, and then set GSS=ISS+1.
> 
> 
> | > Here is the sketch of the solution I was working on, I'd be glad for input:
> | >  * dccp_entail(), skb_clone(), dccp_transmit_skb() and setting of the icsk
> | >    retransmit timer always occur together;
> | >  * as soon as skb_clone() is called, skb->cloned is true;
> | >  * so the idea is to 
> | >    - use dccp_transmit_skb() to transmit the un-cloned skb;
> | >    - sk->send_head = skb_clone(skb, gfp_any())
> | >    - need some more careful analysis, but I think the set_owner_w() can
> | >      also be removed, needs checking against the WARN_ON in
> | >      dccp_transmit_skb().
> | > 
> | > Or maybe there is an easier way - the objective is to have a clear
> | > indicator whether the skb is a retransmitted one or the first one
> | > (since a similar problem arises when sending Close(Req) packets).
> | 
> | ...since I think I got to the same page as you guys... :-) Lets continue
> | from this point:
> | 
> | I think we have to use set_owner_w, its safer, we better get the
> | connection stuck due to using all its socket send buffer space if the
> | packet is never freed because of some stack bug than to get the whole
> | machine with a problem, even if after a long time, if we leak these
> | packets.
> | 
> | Perhaps we can use a flag in skb->cb that we would set only on the first
> | packet? Nah, I think we should have a __dccp_transmit_skb, that... code,
> | lets show it as a patch, see at the end of this message.
> | 
> I had a further look, it is actually possible. Your point about
> set_owner_w is good - I've had to reboot three times today because of
> non-freed references.
> 
> What I found so far is that skb_cloned(skb) in dccp_retransmit_skb is
> never true, since we put the original skb onto the sk->send_head, so
> dccp_retransmit_skb() always calls skb_clone. That is why
> dccp_transmit_skb() never complains that skb->sk is already set.
> 
> What I was hoping for was a rewrite of the dccp_retransmit_skb(), so
> that the original skb is transmitted first and the clone put onto the
> send-head. But doesn't work since queue_xmit frees the original skb, so
> was stuck there.

One thing to always have in mind is that we should, as long as it
remains sane, to try to have the same code structure as TCP, so that
people that are used to the TCP code can read the DCCP more easily and
to identify areas that are are common.

So when trying to change things like this check if TCP has a similar
function and if the change would make sense there too.
 
> | WRT Close(Req) I think it is right as it is, i.e. we should bump GSS, if
> | not we'll send the packet with the same sequence number as the last
> | packet sent, i.e. the problem is just on the very first packet.
> | 
> | Or am I missing something?
> Correct - this applies only to the initial packet, so we can safely
> increment GSS on entering dccp_transmit_skb().
> 
> I will look at your code at home, we will be shutting down here
> everything in 15 minutes.

OK.

- Arnaldo
