From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Dec 2006 10:23:16 +0000
Subject: Re: [PATCH 5/5]: DCCP Fix initial s
Message-Id: <200612211023.16838@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201549.41083.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201549.41083.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  If we set s to first packet size then s is way too low as this is not a
|  data packet. On my system this is 24 bytes (skb->len) and if sending
|  1400 byte packets you are sending at a rate over 50 x too much.
|  
|  More conservative default is mss and follows general principle of being
|  conservative rather than aggressive.

I don't agree with this patch. 
 1) all packets going through ccid3 are data packets 
    (restriction len > 0 in ccid3_hc_tx_send_packet).

 2) your example is specific to iperf, but with other sources the initial
    packet may look different: we should not modify generic kernel code just 
    because with a specific application it looks strange.

 3) we already have the larger initial windows code tackling this issue:
    as soon as the first feedback packet arrives, the 
        min(4*MSS, max(2*MSS, 4380))
    kicks in - which has an even stronger effect than just using 1 * MSS.

OK?

|  
|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
|  ---
|  diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
|  index 1ae4f52..b40cad6 100644
|  --- a/net/dccp/ccids/ccid3.c
|  +++ b/net/dccp/ccids/ccid3.c
|  @@ -342,7 +342,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
|   		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
|   
|   		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
|  -		ccid3_hc_tx_update_s(hctx, skb->len);
|  +		ccid3_hc_tx_update_s(hctx, dp->dccps_mss_cache);
|   		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
|   		hctx->ccid3hctx_x <<= 6;
|   
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
