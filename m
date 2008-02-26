From: "Leandro Sales" <leandroal@gmail.com>
Date: Tue, 26 Feb 2008 13:02:12 +0000
Subject: Re: [PATCH 2/2] [ACKVEC]: Schedule Sync as out-of-band mechanism
Message-Id: <5bc4c4570802260502wb902c4aybca4455bc45b0c39@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1203933122-27140-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1203933122-27140-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2008/2/26, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> Hi Leandro,
>
>  thank you for paying attention and looking closely. Btw - this was not
>  copied to the list?

I just forgot to copy to the list and I was thinking that I just
git-pull the latest dccp branch in a wrong way. I'm playing attention
to all your patches since I have (since a month ago) to backport the
patches to kernel 2.6.21, which I use in Nokia N800/N810 devices that
run linux. I'm using this devices to experiment DCCP and provide an
up-to-date DCCP implementation for them. Before you ask: I have to use
2.6.21 because there are some issues regarding to some proprietary
code like the wifi driver that just work in 2.6.21.

>
>
>  | >  --- a/net/dccp/output.c
>  | >  +++ b/net/dccp/output.c
>  | >  @@ -292,6 +292,8 @@ void dccp_write_xmit(struct sock *sk, in
>  | >                         if (err)
>  | >                                 DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
>  | >                                          err);
>  | >  +                       if (dp->dccps_sync_scheduled)
>  | >  +                               dccp_send_sync(sk, dp->dccps_gsr, DCCP_PKT_SYNC);
>  |
>  | These two lines are not appearing in the latest version of the dccp
>  | branch of you git tree. BTW, this is totally different. Did I do
>  | something wrong while pulling the branch or since this is a
>  | resubmission of your patch, you had to assume that code (nowadays
>  | modified)? In my version, this function uses a switch statement:
>  |
>  | void dccp_write_xmit(struct sock *sk)
>  | {
>  |         struct dccp_sock *dp = dccp_sk(sk);
>  |         struct sk_buff *skb;
>  |
>  |         while ((skb = skb_peek(&sk->sk_write_queue))) {
>  |                 int rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
>  |
>  |                 switch (ccid_packet_dequeue_eval(rc)) {
>  |                 case CCID_PACKET_WILL_DEQUEUE_LATER:
>  |                         return;
>  |                 case CCID_PACKET_DELAY:
>  |                         sk_reset_timer(sk, &dp->dccps_xmit_timer, (jiffies +
>  |                                                         msecs_to_jiffies(rc)));
>  |                         return;
>  |                 case CCID_PACKET_SEND_AT_ONCE:
>  |                         dccp_xmit_packet(sk);
>  |                         break;
>  |                 case CCID_PACKET_ERR:
>  |                         skb_dequeue(&sk->sk_write_queue);
>  |                         kfree_skb(skb);
>  |                         dccp_pr_debug("packet discarded due to err=%d\n", rc);
>  |                 }
>  |         }
>  | }
>
> And this is correct -- the `sync_scheduled' is now executed within
>  dccp_xmit_packet(), a few lines above this function in net/dccp/output.c:

Yes, I just check this function and certified these changes.

>
>         static void dccp_xmit_packet(struct sock *sk)
>         {
>                 // <snip>
>                 // ...
>
>                /*
>                 * If the CCID needs to transfer additional header options out-of-band
>                 * (e.g. Ack Vectors or feature-negotiation options), it activates the
>                 * flag to schedule a Sync. The Sync will automatically incorporate all
>                 * currently valid header options so that this backlog is now cleared.
>                 */
>
>                if (dp->dccps_sync_scheduled)
>                        dccp_send_sync(sk, dp->dccps_gsr, DCCP_PKT_SYNC);
>         }
>
>
> The seeming contradiction comes from the order among the patches: the
>  out-of-band mechanism is introduced earlier, as part of the Ack Vector
>  patches. After the Ack Vector patches there is an update for the
>  dequeueing interface, which stops CCID-2 from polling. If you remove the
>  three following patches from the top of your git tree, you will get the
>  state as described above:
>
>         [CCID2]: Stop polling
>         [CCID]: Refine the wait-for-ccid mechanism
>         [DCCP]: Extend CCID packet dequeueing interface
>
>  The last one introduces the new interface and shifts the sync_scheduled.
>

Yes, I also backport these patches last week for 2.6.21 linux omap kernel.

>
>  Gerrit
>

By the way, I had some issues to solve and I have just finish the
modifications in the dccp plugin for gstreamer today. I will just now
write the release notes, submit the new .tar.gz2 to the
garage.maemo.org (as the previous version) and I will let you know the
link to download it. Thank you for your feedback.

Leandro.
