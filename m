From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 04 Dec 2006 17:42:27 +0000
Subject: Re: [PATCH] DCCP: handle EAGAIN case
Message-Id: <5640c7e00612040942r1e7eeff9g347414747e492ae4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612031538.27300@strip-the-willow>
In-Reply-To: <200612031538.27300@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/5/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  This one doesn't seem right to me because we get EAGAIN in theory only
> |  if packet delay is greater than timeo which is 30 seconds, or timeo is
> |  0, or delay < 0 (which shouldn't happen as msecs_to_jiffies returns
>  a) You helped to uncover at least one real bug here:
>
>     long delay;
>
>     delay = msecs_to_jiffies(rc);
>     if (delay > *timeo || delay < 0)
>

I was thinking of changing the type from long to unsigned long to
match and removing the test too. I agree totally.

>  b) Further test results
>     Below you asked for more testing: on top of the brandnew davem-2.6 (with the last
>     lot of DCCP patches), I can no longer see a serious performance difference.
>     When I unapply the -EAGAIN patch, the error messages (see below) are also no longer present.
>     Performance on 2.4Ghz P4 uniprocessor is up to 51.6Mbit/sec, on a Xeon 3 Ghz SMP it is up to
>     92.2 Mbit/sec (4Mbit/sec less without the patch, but there are likely other influences).
>
Yes - some of these issues seem intermittent. I was also checking
history and there was a bug that timeo wasn't getting reset back to 30
seconds and that occurred fairly recently so you might have missed
that patch.

>
>  c) Why I think that EAGAIN should be considered
>     The value of `timeo' is an arbitrary value set in dccp_write_xmit, it has nothing to do
>     with CCID 3 internals. When the value of *timeo in dccp_wait_for_ccid has reached 0 or
>     if ccid_hc_tx_send_packet() returns a delay value which is greater than the *timeo, the
>     following will happen:
>       - the BUG warning is triggered with the message "err=-11 ..." (see below)
>       - the next step is:
>
>         skb_dequeue(&sk->sk_write_queue
>         if (err = 0) {
>                 /* ... */
>
>         } else
>                 kfree(skb);             /* packet is thrown into the bin */
>
>      ==> The packet is silently discarded and the receiver will register it as a lost packet.
>           I think this is not the `right' way to deal with EAGAIN cases. Again, we can follow
>           your suggestion and keep on testing, but I think this should be handled in a smarter way.
>           In particular, what happens if *timeo = 0 and if the packet (according to CCID 3 calculations)
>           is ready to be sent? Currently it is discarded, which somehow is not right.
>
>      ==> There is another case: interrupted system call ("err=-4 ...", corresponds to -EINTR).
>           I get it for instance when I kill the iperf client with CTRL-C. A more graceful handling
>           of this case seems desirable;
>
Agree on both counts.

> |
> |  If this was the case this line should have triggered and put info in your logs:
> |                       if (err)
> |                               DCCP_BUG("err=%d after dccp_wait_for_ccid", err)
> Yes, it did: the message was "err=-11 ..." (which corresponds to -EAGAIN).
> Stumbling over these error messages was the reason I tested/sent this patch.
>
Understand.

-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
