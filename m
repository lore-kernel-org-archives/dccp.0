From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 03 Dec 2006 21:28:24 +0000
Subject: Re: [PATCH] DCCP: handle EAGAIN case
Message-Id: <5640c7e00612031328w44eb7333lc666b1e32bafd31e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612031538.27300@strip-the-willow>
In-Reply-To: <200612031538.27300@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

This one doesn't seem right to me because we get EAGAIN in theory only
if packet delay is greater than timeo which is 30 seconds, or timeo is
0, or delay < 0 (which shouldn't happen as msecs_to_jiffies returns
unsigned). EAGAIN is only set by dccp_wait_for_ccid.

If this was the case this line should have triggered and put info in your logs:
			if (err)
				DCCP_BUG("err=%d after dccp_wait_for_ccid", err)

Any of these cases indicates a far more fundamental problem and this
is masking it.... Can you put some debug in and find out more. I'll
add some in too once I finish off another testing cycle I'm working
on.

Regards,

Ian

On 12/4/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This might be something to help with the poor throughput.
> By using this patch, I have observed an increase of tx rates
> from  600..800kbits/sec (without this modification) up to 94.8 Mbits/sec
> (which is as good as TCP gets).
> Please test - I'd be curious what your experiences are with this one.
>
> --------------------------> Patch <----------------------------------------
>
> [DCCP]: Handle EAGAIN in dccp_write_xmit
>
> If dccp_wait_for_ccid returns -EAGAIN, the packet is silently
> deqeued and not sent. At the receiver this counts as loss, increases
> the loss rate and reduces throughput.
> This patch handles the EAGAIN case by restarting afresh to peek into
> the write queue and send the packet.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/output.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> --- a/net/dccp/output.c
> +++ b/net/dccp/output.c
> @@ -255,8 +255,11 @@ void dccp_write_xmit(struct sock *sk, in
>                                 err = dccp_wait_for_ccid(sk, skb, &timeo);
>                                 timeo = DCCP_XMIT_TIMEO;
>                         }
> -                       if (err)
> +                       if (err) {
> +                               if (err = -EAGAIN)
> +                                       continue;
>                                 DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
> +                       }
>                 }
>
>                 skb_dequeue(&sk->sk_write_queue);


-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
