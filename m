From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 28 Aug 2008 19:53:15 +0000
Subject: Re: [PATCH 04/37] dccp: Per-socket initialisation of feature
Message-Id: <20080828195315.GK9193@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Aug 28, 2008 at 07:44:39PM +0200, Gerrit Renker escreveu:
> This provides feature-negotiation initialisation for both DCCP sockets and
> DCCP request_sockets, to support feature negotiation during connection setup.
> 
> It also resolves a FIXME regarding the congestion control initialisation.
> 
> Thanks to Wei Yongjun for help with the IPv6 side of this patch.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
>  include/linux/dccp.h |    4 ++++
>  net/dccp/dccp.h      |    3 ++-
>  net/dccp/feat.c      |   19 +++++++++++++++++++
>  net/dccp/feat.h      |    1 +
>  net/dccp/input.c     |    2 --
>  net/dccp/ipv4.c      |    3 ++-
>  net/dccp/ipv6.c      |    3 ++-
>  net/dccp/minisocks.c |    7 ++++++-
>  net/dccp/proto.c     |    1 +
>  9 files changed, 37 insertions(+), 6 deletions(-)
> 
> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -412,6 +412,7 @@ extern void dccp_minisock_init(struct dccp_minisock *dmsk);
>   * @dreq_iss: initial sequence number sent on the Response (RFC 4340, 7.1)
>   * @dreq_isr: initial sequence number received on the Request
>   * @dreq_service: service code present on the Request (there is just one)
> + * @dreq_featneg: feature negotiation options for this connection
>   * The following two fields are analogous to the ones in dccp_sock:
>   * @dreq_timestamp_echo: last received timestamp to echo (13.1)
>   * @dreq_timestamp_echo: the time of receiving the last @dreq_timestamp_echo
> @@ -421,6 +422,7 @@ struct dccp_request_sock {
>  	__u64			 dreq_iss;
>  	__u64			 dreq_isr;
>  	__be32			 dreq_service;
> +	struct list_head	 dreq_featneg;

Wouldn't be better to use hlist here? So that we use 8 bytes less per
struct dccp_request_sock, after all we don't use struct sock while in
embryonic stage exactly to reduce the footprint at this point in the
socket lifetime :-)

>  	__u32			 dreq_timestamp_echo;
>  	__u32			 dreq_timestamp_time;
>  };
> @@ -498,6 +500,7 @@ struct dccp_ackvec;
>   * @dccps_mss_cache - current value of MSS (path MTU minus header sizes)
>   * @dccps_rate_last - timestamp for rate-limiting DCCP-Sync (RFC 4340, 7.5.4)
>   * @dccps_minisock - associated minisock (accessed via dccp_msk)
> + * @dccps_featneg - tracks feature-negotiation state (mostly during handshake)
>   * @dccps_hc_rx_ackvec - rx half connection ack vector
>   * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
>   * @dccps_hc_tx_ccid - CCID used for the sender (or sending half-connection)
> @@ -535,6 +538,7 @@ struct dccp_sock {
>  	__u64				dccps_ndp_count:48;
>  	unsigned long			dccps_rate_last;
>  	struct dccp_minisock		dccps_minisock;
> +	struct list_head		dccps_featneg;

And here as well

>  	struct dccp_ackvec		*dccps_hc_rx_ackvec;
>  	struct ccid			*dccps_hc_rx_ccid;
>  	struct ccid			*dccps_hc_tx_ccid;
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -252,7 +252,8 @@ extern const char *dccp_state_name(const int state);
>  extern void dccp_set_state(struct sock *sk, const int state);
>  extern void dccp_done(struct sock *sk);
>  
> -extern void dccp_reqsk_init(struct request_sock *req, struct sk_buff *skb);
> +extern int  dccp_reqsk_init(struct request_sock *rq, struct dccp_sock const *dp,
> +			    struct sk_buff const *skb);
>  
>  extern int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
>  
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -276,6 +276,25 @@ void dccp_feat_list_purge(struct list_head *fn_list)
>  }
>  EXPORT_SYMBOL_GPL(dccp_feat_list_purge);
>  
> +/* generate @to as full clone of @from - @to must not contain any nodes */
> +int dccp_feat_clone_list(struct list_head const *from, struct list_head *to)
> +{
> +	struct dccp_feat_entry *entry, *new;
> +
> +	INIT_LIST_HEAD(to);
> +	list_for_each_entry(entry, from, node) {
> +		new = dccp_feat_clone_entry(entry);

dccp_feat_clone_entry uses kmemdup for a new dccp_feat_entry _and_
possibly for sp.vec, and goes on adding it to the 'to' list, but if
one fails you go to cloning_failed: and dccp_feat_list_purge will
call just dccp_feat_entry_destructor that doesn't frees the
dccp_feat_entry instances, just the sp.vec. 

Looks like major leakage, or am I missing something?

> +		if (new = NULL)
> +			goto cloning_failed;
> +		list_add_tail(&new->node, to);
> +	}
> +	return 0;
> +
> +cloning_failed:
> +	dccp_feat_list_purge(to);
> +	return -ENOMEM;
> +}
> +
