From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 20 Dec 2006 01:00:46 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix non-conformance to RFC
Message-Id: <5640c7e00612191700i71aa370fg51d0192ce115dea8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612191436.01509.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612191436.01509.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/19/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  @@ -384,6 +384,9 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
> |       packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
> |       packet->dccphtx_sent   = 1;
> |       hctx->ccid3hctx_idle   = 0;
> |  +
> |  +    ccid3_pr_debug("seqno = %llu, rtt = %u\n",
> |  +       (long long unsigned)packet->dccphtx_seqno, packet->dccphtx_rtt);
> |   }
> Is this statement really necessary - both values appear somewhere else and neither is specific
> to ccid3_hc_tx_packet_sent.

I think it is useful. Nowhere else in the send path do we print out
which packet we are sending!

>
>
> |  @@ -158,6 +158,7 @@ enum ccid3_hc_rx_states {
> |    *  @ccid3hcrx_s  -  Received packet size in bytes
> |    *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
> |    *  @ccid3hcrx_elapsed_time  -  Time since packet reception
> |  + *  @ccid3hcrx_seq_recalc_loss - when to recalc loss due to non-loss
> Would it be possible to use a reference to the RFC section here - the entry is slightly confusing.
>
Have done. Will be resending patch soon.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
