From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 28 Aug 2008 20:50:57 +0000
Subject: Re: [PATCH 06/37] dccp: Limit feature negotiation to connection
Message-Id: <20080828205057.GM9193@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Aug 28, 2008 at 07:44:41PM +0200, Gerrit Renker escreveu:
> This patch starts the new implementation of feature negotiation:
>  1. Although it is theoretically possible to perform feature negotiation at any
>     time (and RFC 4340 supports this), in practice this is prohibitively complex,
>     as it requires to put traffic on hold for each new negotiation.
>  2. As a byproduct of restricting feature negotiation to connection setup, the
>     feature-negotiation retransmit timer is no longer required. This part is now
>     mapped onto the protocol-level retransmission.
>     Details indicating why timers are no longer needed can be found on
>     http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/\
> 	                                      implementation_notes.html
> 
> This patch disables anytime negotiation, subsequent patches work out full
> feature negotiation support for connection setup.

While I agree that its better to initially support only negotiation at
connection startup, I wonder if the response to feature negotiation
after connection startup should be plainly ignore the request or if we
should reset the connection, telling the other side that what it wants
to do is not implemented currently.

- Arnaldo
 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/feat.c    |   19 ++++++++-----------
>  net/dccp/options.c |   18 ------------------
>  net/dccp/timer.c   |   12 ------------
>  3 files changed, 8 insertions(+), 41 deletions(-)
> 
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -6,6 +6,8 @@
>   *
>   *  ASSUMPTIONS
>   *  -----------
> + *  o Feature negotiation is coordinated with connection setup (as in TCP), wild
> + *    changes of parameters of an established connection are not supported.
>   *  o All currently known SP features have 1-byte quantities. If in the future
>   *    extensions of RFCs 4340..42 define features with item lengths larger than
>   *    one byte, a feature-specific extension of the code will be required.
> @@ -649,6 +651,9 @@ int dccp_feat_change_recv(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len)
>  {
>  	int rc;
>  
> +	/* Ignore Change requests other than during connection setup */
> +	if (sk->sk_state != DCCP_LISTEN && sk->sk_state != DCCP_REQUESTING)
> +		return 0;
>  	dccp_feat_debug(type, feature, *val);
>  
>  	/* figure out if it's SP or NN feature */
> @@ -698,6 +703,9 @@ int dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
>  	int found = 0;
>  	int all_confirmed = 1;
>  
> +	/* Ignore Confirm options other than during connection setup */
> +	if (sk->sk_state != DCCP_LISTEN && sk->sk_state != DCCP_REQUESTING)
> +		return 0;
>  	dccp_feat_debug(type, feature, *val);
>  
>  	/* locate our change request */
> @@ -732,17 +740,6 @@ int dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
>  			all_confirmed = 0;
>  	}
>  
> -	/* fix re-transmit timer */
> -	/* XXX gotta make sure that no option negotiation occurs during
> -	 * connection shutdown.  Consider that the CLOSEREQ is sent and timer is
> -	 * on.  if all options are confirmed it might kill timer which should
> -	 * remain alive until close is received.
> -	 */
> -	if (all_confirmed) {
> -		dccp_pr_debug("clear feat negotiation timer %p\n", sk);
> -		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
> -	}
> -
>  	if (!found)
>  		dccp_pr_debug("%s(%d, ...) never requested\n",
>  			      dccp_feat_typename(type), feature);
> --- a/net/dccp/options.c
> +++ b/net/dccp/options.c
> @@ -489,7 +489,6 @@ static int dccp_insert_feat_opt(struct sk_buff *skb, u8 type, u8 feat,
>  
>  static int dccp_insert_options_feat(struct sock *sk, struct sk_buff *skb)
>  {
> -	struct dccp_sock *dp = dccp_sk(sk);
>  	struct dccp_minisock *dmsk = dccp_msk(sk);
>  	struct dccp_opt_pend *opt, *next;
>  	int change = 0;
> @@ -530,23 +529,6 @@ static int dccp_insert_options_feat(struct sock *sk, struct sk_buff *skb)
>  		}
>  	}
>  
> -	/* Retransmit timer.
> -	 * If this is the master listening sock, we don't set a timer on it.  It
> -	 * should be fine because if the dude doesn't receive our RESPONSE
> -	 * [which will contain the CHANGE] he will send another REQUEST which
> -	 * will "retrnasmit" the change.
> -	 */
> -	if (change && dp->dccps_role != DCCP_ROLE_LISTEN) {
> -		dccp_pr_debug("reset feat negotiation timer %p\n", sk);
> -
> -		/* XXX don't reset the timer on re-transmissions.  I.e. reset it
> -		 * only when sending new stuff i guess.  Currently the timer
> -		 * never backs off because on re-transmission it just resets it!
> -		 */
> -		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> -					  inet_csk(sk)->icsk_rto, DCCP_RTO_MAX);
> -	}
> -
>  	return 0;
>  }
>  
> --- a/net/dccp/timer.c
> +++ b/net/dccp/timer.c
> @@ -87,17 +87,6 @@ static void dccp_retransmit_timer(struct sock *sk)
>  {
>  	struct inet_connection_sock *icsk = inet_csk(sk);
>  
> -	/* retransmit timer is used for feature negotiation throughout
> -	 * connection.  In this case, no packet is re-transmitted, but rather an
> -	 * ack is generated and pending changes are placed into its options.
> -	 */
> -	if (sk->sk_send_head = NULL) {
> -		dccp_pr_debug("feat negotiation retransmit timeout %p\n", sk);
> -		if (sk->sk_state = DCCP_OPEN)
> -			dccp_send_ack(sk);
> -		goto backoff;
> -	}
> -
>  	/*
>  	 * More than than 4MSL (8 minutes) has passed, a RESET(aborted) was
>  	 * sent, no need to retransmit, this sock is dead.
> @@ -126,7 +115,6 @@ static void dccp_retransmit_timer(struct sock *sk)
>  		return;
>  	}
>  
> -backoff:
>  	icsk->icsk_backoff++;
>  
>  	icsk->icsk_rto = min(icsk->icsk_rto << 1, DCCP_RTO_MAX);
> -- 
> 1.6.0.rc2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
