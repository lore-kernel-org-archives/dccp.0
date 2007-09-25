From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 25 Sep 2007 18:50:41 +0000
Subject: Re: [PATCH 7/8]: Handle timestamps on Request/Response exchange
Message-Id: <20070925185041.GH18348@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.48514@strip-the-willow>
In-Reply-To: <200709251530.48514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Sep 25, 2007 at 03:30:48PM +0100, Gerrit Renker escreveu:
> [DCCP]: Handle timestamps on Request/Response exchange separately
> 
> In DCCP, timestamps can occur on packets anytime, CCID3 uses a timestamp(/echo) on the Request/Response
> exchange. This patch addresses the following situation:
> 	* timestamps are recorded on the listening socket;

I noticed this, I think it is unaceptable to do that, therefore the best
thing is to combine the two patches, so as not to introduce a problem
that is fixed in the following patch.

Look below for some other considerations.

> 	* Responses are sent from dccp_request_sockets;
> 	* suppose two connections reach the listening socket with very small time in between:
> 	* the first timestamp value gets overwritten by the second connection request.
> 
> It may seem unlikely that this bug will occur, since the Response is sent out immediately, but to me 
> this does not seem right. I am further not sure whether the socket locks provide sufficient protection
> against overwriting timestamp values on the listening socket.

It is just wrong, I cannot see anything that would prevent this window
from being hit.
 
> This patch therefore
> 	* makes memory use for timestamps dynamic (to use less when no timestamps are present);
> 	* separates `handshake timestamps' from `established timestamps';

I didn't understood this one. Care to further explain? Anyway, I think
that adding yet another allocation in a connection lifetime is not good.
One of the most pressing things for me after merging all the patches
that are pending (THANK YOU! :-) ) is to work on DCCP memory consuption
and accounting, the code has to be made more robust :-\

I think that we should just add dreq_{time,echo} to dccp_request_sock
and keep dccp_sock as is.

Now it is:

[acme@mica net-2.6.24]$ pahole -C dccp_request_sock net/dccp/minisocks.o
struct dccp_request_sock {
        struct inet_request_sock dreq_inet_rsk; /*  0 56 */
        __u64                    dreq_iss;      /* 56  8 */
        /* --- cacheline 1 boundary (64 bytes) --- */
        __u64                    dreq_isr;      /* 64  8 */
        __be32                   dreq_service;  /* 72  4 */

        /* size: 76, cachelines: 2 */
        /* last cacheline: 12 bytes */
};

I suggest it to become:

[acme@mica net-2.6.24]$ pahole -C dccp_request_sock net/dccp/minisocks.o

struct dccp_request_sock {
        struct inet_request_sock dreq_inet_rsk;    /*  0 56 */
        __u64                    dreq_iss;         /* 56  8 */
        /* --- cacheline 1 boundary (64 bytes) --- */
        __u64                    dreq_isr;         /* 64  8 */
        __be32                   dreq_service;     /* 72  4 */
        __u32                    dreq_tstamp_echo; /* 76  4 */
        ktime_t                  dreq_tstamp_time; /* 80  8 */

        /* size: 88, cachelines: 2 */
        /* last cacheline: 24 bytes */
};

Humm, these minisocks are getting fat... another thing for my TODO list,
request_sock::ts_recent seems to be used only by the TCP machinery, ripe
for the picking....

Anyway, I'll move along the patch queue looking for more easily
cherrypickable patches.

> 	* de-allocates in request socket destructor if previous de-allocation has failed.
> 
> Furthermore, inserting the Timestamp Echo option has been taken out of the block starting with 
> '!dccp_packet_without_ack()', since Timestamp Echo can be carried on any packet (5.8 and 13.3).

Well, not really, a timestamp echo on a request packet would make no
sense :-) But yeah, the code right now its wrong as it doesn't puts
timestamp echo options in data packets, and that is allowed.

> Lastly, with sampling RTTs in mind, the earliest-unacknowledged timestamp is always kept on the
> socket (mimicking RFC 1323). This is not fully worked out, to do a RFC1323-style algorithm requires
> more work, and possibly some changes; but in can in principle benefit from the provided code.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  include/linux/dccp.h |   25 +++++++++++++++++++++----
>  net/dccp/dccp.h      |    2 +-
>  net/dccp/ipv4.c      |    4 ++++
>  net/dccp/ipv6.c      |    4 ++++
>  net/dccp/minisocks.c |    4 ++++
>  net/dccp/options.c   |   41 +++++++++++++++++++++++++++--------------
>  net/dccp/proto.c     |    5 +++++
>  7 files changed, 66 insertions(+), 19 deletions(-)
> 
> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -407,11 +407,30 @@ struct dccp_opt_pend {
>  
>  extern void dccp_minisock_init(struct dccp_minisock *dmsk);
>  
> +/**
> + * struct dccp_ts_echo  -  Record incoming timestamp to echo it later
> + * @ts_time: arrival time of timestamp
> + * @ts_echo: the timestamp value recorded at @ts_time
> + */
> +struct dccp_ts_echo {
> +	ktime_t		ts_time;
> +	__u32		ts_echo;
> +};
> +
> +/**
> + * struct dccp_request_sock  -  represent DCCP-specific connection request
> + * @dreq_inet_rsk: structure inherited from
> + * @dreq_iss: initial sequence number sent on the Response (RFC 4340, 7.1)
> + * @dreq_isr: initial sequence number received on the Request
> + * @dreq_service: service code present on the Request (there is just one)
> + * @dreq_tstamp: most recent timestamp received during connection setup
> + */
>  struct dccp_request_sock {
>  	struct inet_request_sock dreq_inet_rsk;
>  	__u64			 dreq_iss;
>  	__u64			 dreq_isr;
>  	__be32			 dreq_service;
> +	struct dccp_ts_echo	 *dreq_tstamp;
>  };
>  
>  static inline struct dccp_request_sock *dccp_rsk(const struct request_sock *req)
> @@ -477,8 +496,7 @@ struct dccp_ackvec;
>   * @dccps_gar - greatest valid ack number received on a non-Sync; initialized to %dccps_iss
>   * @dccps_service - first (passive sock) or unique (active sock) service code
>   * @dccps_service_list - second .. last service code on passive socket
> - * @dccps_timestamp_time - time of latest TIMESTAMP option
> - * @dccps_timestamp_echo - latest timestamp received on a TIMESTAMP option
> + * @dccps_tstamp - most recently received timestamp to echo (RFC 4340, 13.1)
>   * @dccps_l_ack_ratio - feature-local Ack Ratio
>   * @dccps_r_ack_ratio - feature-remote Ack Ratio
>   * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
> @@ -514,8 +532,7 @@ struct dccp_sock {
>  	__u64				dccps_gar;
>  	__be32				dccps_service;
>  	struct dccp_service_list	*dccps_service_list;
> -	ktime_t				dccps_timestamp_time;
> -	__u32				dccps_timestamp_echo;
> +	struct dccp_ts_echo		*dccps_tstamp;
>  	__u16				dccps_l_ack_ratio;
>  	__u16				dccps_r_ack_ratio;
>  	__u16				dccps_pcslen;
> --- a/net/dccp/options.c
> +++ b/net/dccp/options.c
> @@ -56,6 +56,7 @@ int dccp_parse_options(struct sock *sk, 
>  	const unsigned char *opt_end = (unsigned char *)dh +
>  					(dh->dccph_doff * 4);
>  	struct dccp_options_received *opt_recv = &dp->dccps_options_received;
> +	struct dccp_ts_echo **tse;
>  	unsigned char opt, len;
>  	unsigned char *value;
>  	u32 elapsed_time, opt_val;
> @@ -159,12 +160,25 @@ int dccp_parse_options(struct sock *sk, 
>  			if (len != 4)
>  				goto out_invalid_option;
>  
> +			tse = dreq? &dreq->dreq_tstamp : dp->dccps_tstamp;

huh? both dreq_tstamp and dccps_tstamp are pointers to dccp_ts_echo, you
are mixing pointer types here by using '&' on one and not on the other
:)

> +			/*
> +			 * Keep the earliest received timestamp on the socket,
> +			 * until echoing to the peer frees it. This policy is
> +			 * useful for doing RTT measurements (eg. RFC 1323, 3.4)
> +			 */
> +			if (*tse != NULL)
> +				break;
> +
> +			*tse = kmalloc(sizeof(struct dccp_ts_echo), GFP_ATOMIC);
> +			if (*tse = NULL) {
> +				DCCP_CRIT("can not store received timestamp");

we avoid this situation by having the dccp_ts_echo fields in the
minisock and keeping dccp_sock as is now.

> +				break;
> +			}
> +
> +			(*tse)->ts_time = ktime_get_real();
>  			opt_val = get_unaligned((u32 *)value);
>  			opt_recv->dccpor_timestamp = ntohl(opt_val);
> -
> -			/* FIXME: if dreq != NULL, don't store this on listening socket */
> -			dp->dccps_timestamp_echo = opt_recv->dccpor_timestamp;
> -			dp->dccps_timestamp_time = ktime_get_real();
> +			(*tse)->ts_echo = opt_recv->dccpor_timestamp;
>  
>  			dccp_pr_debug("%s rx opt: TIMESTAMP=%u, ackno=%llu\n",
>  				      dccp_role(sk), opt_recv->dccpor_timestamp,
> @@ -384,15 +398,14 @@ int dccp_insert_option_timestamp(struct 
>  
>  EXPORT_SYMBOL_GPL(dccp_insert_option_timestamp);
>  
> -static int dccp_insert_option_timestamp_echo(struct sock *sk,
> +static int dccp_insert_option_timestamp_echo(struct dccp_ts_echo **tse,
>  					     struct sk_buff *skb)
>  {
> -	struct dccp_sock *dp = dccp_sk(sk);
>  	__be32 tstamp_echo;
>  	int len, elapsed_time_len;
>  	unsigned char *to;
>  	const suseconds_t delta = ktime_us_delta(ktime_get_real(),
> -						 dp->dccps_timestamp_time);
> +						 (*tse)->ts_time);
>  	u32 elapsed_time = delta / 10;
>  	elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
>  	len = 6 + elapsed_time_len;
> @@ -406,7 +419,7 @@ static int dccp_insert_option_timestamp_
>  	*to++ = DCCPO_TIMESTAMP_ECHO;
>  	*to++ = len;
>  
> -	tstamp_echo = htonl(dp->dccps_timestamp_echo);
> +	tstamp_echo = htonl((*tse)->ts_echo);
>  	memcpy(to, &tstamp_echo, 4);
>  	to += 4;
>  
> @@ -418,8 +431,8 @@ static int dccp_insert_option_timestamp_
>  		memcpy(to, &var32, 4);
>  	}
>  
> -	dp->dccps_timestamp_echo = 0;
> -	dp->dccps_timestamp_time = ktime_set(0, 0);
> +	kfree(*tse);
> +	*tse = NULL;
>  	return 0;
>  }
>  
> @@ -528,10 +541,6 @@ int dccp_insert_options(struct sock *sk,
>  		    dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
>  		    dccp_insert_option_ackvec(sk, skb))
>  			return -1;
> -
> -		if (dp->dccps_timestamp_echo != 0 &&
> -		    dccp_insert_option_timestamp_echo(sk, skb))
> -			return -1;
>  	}
>  
>  	if (dp->dccps_hc_rx_insert_options) {
> @@ -555,6 +564,10 @@ int dccp_insert_options(struct sock *sk,
>  	    dccp_insert_option_timestamp(sk, skb))
>  		return -1;
>  
> +	if (dp->dccps_tstamp != NULL &&
> +	    dccp_insert_option_timestamp_echo(&dp->dccps_tstamp, skb))
> +		return -1;
> +
>  	/* XXX: insert other options when appropriate */
>  
>  	if (DCCP_SKB_CB(skb)->dccpd_opt_len != 0) {
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -413,7 +413,7 @@ static inline void dccp_update_gss(struc
>  static inline int dccp_ack_pending(const struct sock *sk)
>  {
>  	const struct dccp_sock *dp = dccp_sk(sk);
> -	return dp->dccps_timestamp_echo != 0 ||
> +	return dp->dccps_tstamp != NULL ||
>  #ifdef CONFIG_IP_DCCP_ACKVEC
>  	       (dccp_msk(sk)->dccpms_send_ack_vector &&
>  		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
> --- a/net/dccp/minisocks.c
> +++ b/net/dccp/minisocks.c
> @@ -120,6 +120,7 @@ struct sock *dccp_create_openreq_child(s
>  		newdp->dccps_role	   = DCCP_ROLE_SERVER;
>  		newdp->dccps_hc_rx_ackvec  = NULL;
>  		newdp->dccps_service_list  = NULL;
> +		newdp->dccps_tstamp	   = NULL;
>  		newdp->dccps_service	   = dreq->dreq_service;
>  		newicsk->icsk_rto	   = DCCP_TIMEOUT_INIT;
>  
> @@ -303,9 +304,12 @@ EXPORT_SYMBOL_GPL(dccp_reqsk_send_ack);
>  
>  void dccp_reqsk_init(struct request_sock *req, struct sk_buff *skb)
>  {
> +	struct dccp_request_sock *dreq = dccp_rsk(req);
> +
>  	inet_rsk(req)->rmt_port = dccp_hdr(skb)->dccph_sport;
>  	inet_rsk(req)->acked	= 0;
>  	req->rcv_wnd		= sysctl_dccp_feat_sequence_window;
> +	dreq->dreq_tstamp	= NULL;
>  }
>  
>  EXPORT_SYMBOL_GPL(dccp_reqsk_init);
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -254,6 +254,11 @@ int dccp_destroy_sock(struct sock *sk)
>  	kfree(dp->dccps_service_list);
>  	dp->dccps_service_list = NULL;
>  
> +	if (dp->dccps_tstamp != NULL) {
> +		kfree(dp->dccps_tstamp);
> +		dp->dccps_tstamp = NULL;
> +	}
> +
>  	if (dmsk->dccpms_send_ack_vector) {
>  		dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
>  		dp->dccps_hc_rx_ackvec = NULL;
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -551,6 +551,10 @@ out:
>  
>  static void dccp_v4_reqsk_destructor(struct request_sock *req)
>  {
> +	struct dccp_request_sock *dreq = dccp_rsk(req);
> +
> +	if (dreq->dreq_tstamp != NULL)
> +		kfree(dreq->dreq_tstamp);
>  	kfree(inet_rsk(req)->opt);
>  }
>  
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -295,6 +295,10 @@ done:
>  
>  static void dccp_v6_reqsk_destructor(struct request_sock *req)
>  {
> +	struct dccp_request_sock *dreq = dccp_rsk(req);
> +
> +	if (dreq->dreq_tstamp != NULL)
> +		kfree(dreq->dreq_tstamp);
>  	if (inet6_rsk(req)->pktopts != NULL)
>  		kfree_skb(inet6_rsk(req)->pktopts);
>  }
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
