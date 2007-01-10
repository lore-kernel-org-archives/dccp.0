From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 10 Jan 2007 10:13:43 +0000
Subject: Re: NAK: [PATCH 1/1] DCCP: Fix up t_nom
Message-Id: <200701101013.43364@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701081128.10177@strip-the-willow>
In-Reply-To: <200701081128.10177@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello,

below I have corrected where you pointed out that I was wrong. 

However, I think we are both barking up the wrong tree here, i.e. I'd say that neither your or my patch is
`better', but rather: the evil lies somewhere else. So no matter which patch lands in Arnaldos tree, the main
problem will be unresolved irrespectively.

Both patches, when we put aside other quibbles here, are in effect a variation of the same theme. 


|  >  1) The race condition is not tackled. As before, you allow several routines running
|  >     asynchronously in software interrupts (timer interrupt, net backlog softirq) and
|  >     in user context (dccp_sendmsg) to write/read on t_nom. Without locking, you will
|  >     have the race condition that one routine performs a write (e.g. sub_usecs) while
|  >     another performs a read and sends the packet to early.
|  
|  I don't believe so. For a start now I'm only altering t_nom in one
|  place except for the initial setup which I'll discuss later. And in
|  addition I'm only doing additions apart from initial setup. As such I
|  believe mine is just as safe or more so. 
Went through the patch again and have to agree: there is only the subtraction in rx_packet_recv,
which would be debatable. So your patch also, by and large, tries to avoid the race condition
by monopolising the access to t_nom. Sorry I didn't realize earlier.


|  > I am not in support of this patch. This patch is against _working_ code. Instead of solving
|  > problems, it introduces new ones.
|  >
|  > Can I suggest that we spent our time more profitably on fixing the many bugs that exist?
|  > Fix broken, not working code.
|  >
|  I am fixing broken code. I don't think either of our initial solutions
|  were correct.
I agree but my point is that we are wasting our energy on a discussion of patches which, by and
large, effect the same: before you sent this email, I had consulted with colleagues about this
and will send the notes in a follow-up email.

  
|  > |               hctx->ccid3hctx_t_nom = now;
|  > |  +            timeval_add_usecs(&hctx->ccid3hctx_t_nom, USEC_PER_SEC);
|  > BUG: The first packet will be delayed for 1 second instead of being sent immediately as specified
|  >      in RFC 3448, 4.6.
|  >
|  No you are reading my code incorrectly. It breaks out of the switch
|  and sends immediately as returns 0.
You are right and I had meant to point this out in a follow-up: the code above has the same effect as
before, there is no delay. Sorry.

|  > |  @@ -486,6 +474,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
|  > |                       hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
|  > |                       hctx->ccid3hctx_t_ld = now;
|  > |
|  > |  +                    timeval_sub_usecs(&hctx->ccid3hctx_t_nom, USEC_PER_SEC);
|  > |                       ccid3_update_send_time(hctx);
|  > Why this complicated code - it was simpler before. Now you first add 1 second, then send the packet
|  > immediately and then you subtract again.
|  >
|  Overall I think this is much simpler. Before we were adding and
|  subtracting with each change but now we are doing only on the first
|  feedback (not immediately as you say)
The race-condition patch also removes the add/subtract pair. Please let me restate the above - I think it
is a matter of programming taste - your patch does affect some simplification, mine also does; but I'd
say neither is `better'.

|  
|  > |  @@ -539,11 +528,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
|  > |  -            /*
|  > |  -             * Schedule no feedback timer to expire in
|  > |  -             * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
|  > |  -             */
|  > |  -            t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
|  > |  +            t_nfb = hctx->ccid3hctx_t_rto;
|  > |
|  > BUG: This removes conformance with RFC 3448, section 4.3 and section 4.4.
|  >
|  I think I see what you are saying but the code is/was wrong here.
|  Section 4.3 and 4.4 talks about t_mbi, not t_ipi. t_mbi is a constant
|  of 64 seconds. 
I meant the passages where the nofeedback timer is set to expire after max(4*R, 2*s/X), where t_ipi = s/X.
Now it is only reset to max(4*R). However - again this is a sideline and not central to what I think your
patch tries to achieve. 


|  can you move the refactor patch one up in the sequence so
I have shifted it up by 4 - from 3f to 3a - and refreshed the offsets of the other patches.



			Summary of differences
			----------------------

I would like to come to a kind of settlement for this discussion. We are both arguing that each of our 
patches is `better', but I think this discussion leads nowhere, since the real problems (see follow-up) 
remain untouched.

Taking the subtraction in packet_recv aside, I think it the patch I submitted the exclusive access to
t_nom is clearer to see. In your solution, the access is within a function (ccid3_update_send_time), which
could end up being called by other functions and thus reintroduce the race condition through the back door.
It is safe only because this function has only a single caller at the moment. 
In the patch I submitted (3d/3e) t_nom is only updated within send_packet and not via a function which
is available to other ccid3 routines. Recomputing t_ipi and delta on each send is slightly more expensive.
