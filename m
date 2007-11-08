From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 08 Nov 2007 01:31:35 +0000
Subject: Re: [PATCH 7/9] [CCID2]: Remove redundant synchronisation variable
Message-Id: <5640c7e00711071731h7b7416e4x14298d800e72283f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031323.55965@strip-the-willow>
In-Reply-To: <200711031323.55965@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This removes the synchronisation variable `ccid2hctx_sendwait', which is set to 1
> when the CCID2 sender may send a new packet, and which is set to 0 otherwise
>
> The variable is redundant, since it is only used in combination with the hc_tx_send_packet/
> hc_tx_packet_sent function pair. Both functions are called under socket lock, so the
> following happens when the CCID2 may send a new packet:
>
>  * it sets sendwait = 1 in tx_send_packet and returns 0;
>  * the subsequent call to tx_packet_sent clears the sendwait flag;
>  * since tx_send_packet returns 0 if and only if sendwait = 1, the BUG_ON condition
>    in tx_packet_sent is never satisfied, since that function is never called when
>    tx_send_packet returns a value different from 0 (cf. dccp_write_xmit);
>  * the call to tx_packet_sent clears the flag so that the condition "!sendwait" is
>    true the next time tx_packet_sent is called.
>
> In other words, it is sufficient to just return 0 / not-0 to synchronise tx_send_packet
> and tx_packet_sent -- which is what the patch does.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
