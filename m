From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 28 Dec 2006 03:41:36 +0000
Subject: Re: [PATCH 5/5]: DCCP Fix initial s
Message-Id: <5640c7e00612271941p5380ce29g13f92236c4fdb441@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201549.41083.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201549.41083.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/21/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  If we set s to first packet size then s is way too low as this is not a
> |  data packet. On my system this is 24 bytes (skb->len) and if sending
> |  1400 byte packets you are sending at a rate over 50 x too much.
> |
> |  More conservative default is mss and follows general principle of being
> |  conservative rather than aggressive.
>
> I don't agree with this patch.
>  1) all packets going through ccid3 are data packets
>     (restriction len > 0 in ccid3_hc_tx_send_packet).
>
>  2) your example is specific to iperf, but with other sources the initial
>     packet may look different: we should not modify generic kernel code just
>     because with a specific application it looks strange.
>
>  3) we already have the larger initial windows code tackling this issue:
>     as soon as the first feedback packet arrives, the
>         min(4*MSS, max(2*MSS, 4380))
>     kicks in - which has an even stronger effect than just using 1 * MSS.
>
> OK?

Gerrit,

I checked other applications and you are right - this is specific to
iperf. Dropping this patch from my series.

Thanks for looking into this.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
