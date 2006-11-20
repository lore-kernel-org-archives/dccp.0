From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 20 Nov 2006 20:15:15 +0000
Subject: Re: [PATCH 3/3] DCCP: Remove unneeded variable
Message-Id: <5640c7e00611201215u68c46313n9c957a10893c32a8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611191552.40380.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200611191552.40380.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

Comments inline.

On 11/21/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I am not very happy with this - I think the receiver half-connection RTT code should be revised.

I agree totally. At the moment the code is in a barely working state
where before it didn't work at all. This patch is just to remove a
(currently) unused variable and isn't claiming to fix anything.

> At the present I fail to see why, in ccid3_hc_rx_packet_recv,
>
>         * RTT is only updated on Acks/DataAcks

Yes CCID3 is wrong here. From memory with CCID3 an ACK should come
every 1/4 RTT.

>         * i.e. either AckVectors need to be in place or sender must at the same time
>           be receiver (otherwise it will only get Data packets, never Ack/DataAck)

From memory again Ack Vectors are only CCID2?? I know that turning
them on used to lock the machine when using CCID3.

>         * ... comments as per discussion before
>         * this is likely a new ToDo, but I would not call it fixed
>         * think I found the code Ian was talking about: it is in ccid3_hc_rx_update_li,
>                                                         which has a FIXME

Yes that is one of the primary ones to meet RFC complaince.
>
> Anyway, I have uploaded it to the webpage just the same.
>
> Quoting Ian McDonald:
> |  diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
> |  index 2fa0c6d..55b972b 100644
> |  --- a/net/dccp/ccids/ccid3.c
> |  +++ b/net/dccp/ccids/ccid3.c
> |  @@ -982,7 +982,6 @@ static void ccid3_hc_rx_packet_recv(stru
> |       const struct dccp_options_received *opt_recv;
> |       struct dccp_rx_hist_entry *packet;
> |       struct timeval now;
> |  -    u8 win_count;
> |       u32 p_prev, rtt_prev, r_sample, t_elapsed;
> |       int loss;
> |
> |  @@ -1038,8 +1037,6 @@ static void ccid3_hc_rx_packet_recv(stru
> |               return;
> |       }
> |
> |  -    win_count = packet->dccphrx_ccval;
> |  -
> |       loss = ccid3_hc_rx_detect_loss(sk, packet);
> |
> |       if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)

Ian

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
