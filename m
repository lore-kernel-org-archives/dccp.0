From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 13 Jan 2007 04:54:23 +0000
Subject: Re: NAK: [PATCH 1/1] DCCP: Fix up t_nom
Message-Id: <5640c7e00701122054s341fc025sca63d6e2ce1a922@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701081128.10177@strip-the-willow>
In-Reply-To: <200701081128.10177@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there,

On 10/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hello,
>
> |
> |  > |  @@ -539,11 +528,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
> |  > |  -            /*
> |  > |  -             * Schedule no feedback timer to expire in
> |  > |  -             * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
> |  > |  -             */
> |  > |  -            t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
> |  > |  +            t_nfb = hctx->ccid3hctx_t_rto;
> |  > |
> |  > BUG: This removes conformance with RFC 3448, section 4.3 and section 4.4.
> |  >
> |  I think I see what you are saying but the code is/was wrong here.
> |  Section 4.3 and 4.4 talks about t_mbi, not t_ipi. t_mbi is a constant
> |  of 64 seconds.
> I meant the passages where the nofeedback timer is set to expire after max(4*R, 2*s/X), where t_ipi = s/X.
> Now it is only reset to max(4*R). However - again this is a sideline and not central to what I think your
> patch tries to achieve.
>
I've reworked the patch to not make changes here as I reread the spec
and you are right. This means I keep t_ipi in the structure.

>
> |  can you move the refactor patch one up in the sequence so
> I have shifted it up by 4 - from 3f to 3a - and refreshed the offsets of the other patches.
>
Thanks. I'm now in agreement with all your patches except 3d, 3e, 4e.
If you want to you can move the other ones in front of these three so
Arnaldo has a list of agreed patches.

I'm about to send my revised patch which I believe should replace 3d and 3e.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
