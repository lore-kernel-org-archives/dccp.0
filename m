From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 09 Jan 2007 22:55:25 +0000
Subject: Re: NAK: [PATCH 1/1] DCCP: Fix up t_nom
Message-Id: <5640c7e00701091455v132e2724xad4c9f932034b4d5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701081128.10177@strip-the-willow>
In-Reply-To: <200701081128.10177@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

Comments inline.

On 09/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Due to the following reasons:
>  1) The race condition is not tackled. As before, you allow several routines running
>     asynchronously in software interrupts (timer interrupt, net backlog softirq) and
>     in user context (dccp_sendmsg) to write/read on t_nom. Without locking, you will
>     have the race condition that one routine performs a write (e.g. sub_usecs) while
>     another performs a read and sends the packet to early.

I don't believe so. For a start now I'm only altering t_nom in one
place except for the initial setup which I'll discuss later. And in
addition I'm only doing additions apart from initial setup. As such I
believe mine is just as safe or more so. I have not observed any
problems in testing and the only way either of our patches could be
more robust is with locking. However I don't think this is needed from
my observation and logging.

>  2) It introduces new problems / BUGs that did not previously exist - please see inline.

Discussed inline.

>  3) By removing t_ipi you are now recalculating it each time a packet is sent - which is
>     far more expensive then only recomputing it when related data changes. This will
>     indeed contribute to slow-down.
>
Re-read section 4.6 of RFC3448. We are required to use s and X_inst
and the current code base does not update these every packet we
transmit. It is simpler to do it the way specified in the RFC. My
patch removes some of these comparisons so not all bad.

> I am not in support of this patch. This patch is against _working_ code. Instead of solving
> problems, it introduces new ones.
>
> Can I suggest that we spent our time more profitably on fixing the many bugs that exist?
> Fix broken, not working code.
>
I am fixing broken code. I don't think either of our initial solutions
were correct.

>
> |  We are calculating t_nom in the past we have made it far too complicated
> |  and not matching the RFC.
> What made you come to this conclusion?
>
Reading the RFC as per above.

> |               hctx->ccid3hctx_t_nom = now;
> |  +            timeval_add_usecs(&hctx->ccid3hctx_t_nom, USEC_PER_SEC);
> BUG: The first packet will be delayed for 1 second instead of being sent immediately as specified
>      in RFC 3448, 4.6.
>
No you are reading my code incorrectly. It breaks out of the switch
and sends immediately as returns 0.

> |               break;
> |       case TFRC_SSTATE_NO_FBACK:
> |       case TFRC_SSTATE_FBACK:
> |  @@ -361,6 +351,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
> |                       return delay / 1000L;
> |
> |               ccid3_hc_tx_update_win_count(hctx, &now);
> |  +            ccid3_update_send_time(hctx);
> Recalculating t_ipi, t_delta, and t_nom each time a packet is sent - very expensive.
>
It is slightly more expensive but we are removing other cases

>
>
> |  @@ -486,6 +474,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
> |                       hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
> |                       hctx->ccid3hctx_t_ld = now;
> |
> |  +                    timeval_sub_usecs(&hctx->ccid3hctx_t_nom, USEC_PER_SEC);
> |                       ccid3_update_send_time(hctx);
> Why this complicated code - it was simpler before. Now you first add 1 second, then send the packet
> immediately and then you subtract again.
>
Overall I think this is much simpler. Before we were adding and
subtracting with each change but now we are doing only on the first
feedback (not immediately as you say)

> |  @@ -539,11 +528,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
> |  -            /*
> |  -             * Schedule no feedback timer to expire in
> |  -             * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
> |  -             */
> |  -            t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
> |  +            t_nfb = hctx->ccid3hctx_t_rto;
> |
> BUG: This removes conformance with RFC 3448, section 4.3 and section 4.4.
>
I think I see what you are saying but the code is/was wrong here.
Section 4.3 and 4.4 talks about t_mbi, not t_ipi. t_mbi is a constant
of 64 seconds. So the code was wrong, I've removed it and it's still
wrong but in a different way.

Can I ask one favour? Why we still carry on debating which approach is
better can you move the refactor patch one up in the sequence so
Arnaldo can merge a set of undisputed patches? We'll get this one
sorted I know but we may as well get merged the ones we both agree on
just fine!

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
