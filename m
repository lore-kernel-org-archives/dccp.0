From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 08 Jan 2007 11:28:09 +0000
Subject: NAK: [PATCH 1/1] DCCP: Fix up t_nom
Message-Id: <200701081128.10177@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Due to the following reasons:
 1) The race condition is not tackled. As before, you allow several routines running
    asynchronously in software interrupts (timer interrupt, net backlog softirq) and
    in user context (dccp_sendmsg) to write/read on t_nom. Without locking, you will
    have the race condition that one routine performs a write (e.g. sub_usecs) while
    another performs a read and sends the packet to early. 
 2) It introduces new problems / BUGs that did not previously exist - please see inline.
 3) By removing t_ipi you are now recalculating it each time a packet is sent - which is
    far more expensive then only recomputing it when related data changes. This will 
    indeed contribute to slow-down.
 
I am not in support of this patch. This patch is against _working_ code. Instead of solving
problems, it introduces new ones.

Can I suggest that we spent our time more profitably on fixing the many bugs that exist?
Fix broken, not working code.


|  We are calculating t_nom in the past we have made it far too complicated
|  and not matching the RFC.
What made you come to this conclusion?

|  @@ -275,11 +266,10 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
|   			ccid3_hc_tx_update_x(sk, &now);
|   		}
|   		/*
|  -		 * Schedule no feedback timer to expire in
|  -		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
|  +		 * Schedule no feedback timer to expire in t_RTO
|   		 * See comments in packet_recv() regarding the value of t_RTO.
|   		 */
|  -		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
|  +		t_nfb = hctx->ccid3hctx_t_rto;
|   		break;
|   	case TFRC_SSTATE_NO_SENT:
|   		DCCP_BUG("%s(%p) - Illegal state NO_SENT", dccp_role(sk), sk);
|  @@ -337,13 +327,13 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
|   		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
|   		hctx->ccid3hctx_x <<= 6;
|   
|  -		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
|  -		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
|   		/* Initial delta: minimum of 0.5 sec and t_gran/2 */
|   		hctx->ccid3hctx_delta = TFRC_OPSYS_HALF_TIME_GRAN;
|   
|   		/* Set t_0 for initial packet */
|  +		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
|   		hctx->ccid3hctx_t_nom = now;
|  +		timeval_add_usecs(&hctx->ccid3hctx_t_nom, USEC_PER_SEC);
BUG: The first packet will be delayed for 1 second instead of being sent immediately as specified
     in RFC 3448, 4.6.

|   		break;
|   	case TFRC_SSTATE_NO_FBACK:
|   	case TFRC_SSTATE_FBACK:
|  @@ -361,6 +351,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
|   			return delay / 1000L;
|   
|   		ccid3_hc_tx_update_win_count(hctx, &now);
|  +		ccid3_update_send_time(hctx);
Recalculating t_ipi, t_delta, and t_nom each time a packet is sent - very expensive.



|  @@ -486,6 +474,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
|   			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
|   			hctx->ccid3hctx_t_ld = now;
|   
|  +			timeval_sub_usecs(&hctx->ccid3hctx_t_nom, USEC_PER_SEC);
|   			ccid3_update_send_time(hctx);
|   
|   			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
Why this complicated code - it was simpler before. Now you first add 1 second, then send the packet
immediately and then you subtract again.

|  @@ -539,11 +528,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
|   		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
|   						   CONFIG_IP_DCCP_CCID3_RTO *
|   						   (USEC_PER_SEC/1000));
|  -		/*
|  -		 * Schedule no feedback timer to expire in
|  -		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
|  -		 */
|  -		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
|  +		t_nfb = hctx->ccid3hctx_t_rto;
|   
|   		ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
|   			       "expire in %lu jiffies (%luus)\n",
BUG: This removes conformance with RFC 3448, section 4.3 and section 4.4.
