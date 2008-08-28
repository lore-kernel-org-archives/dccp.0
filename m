From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 28 Aug 2008 21:26:30 +0000
Subject: Re: [PATCH 13/37] dccp: Deprecate Ack Ratio sysctl
Message-Id: <20080828212630.GR9193@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Aug 28, 2008 at 07:44:48PM +0200, Gerrit Renker escreveu:
> This patch deprecates the Ack Ratio sysctl, since
>  * Ack Ratio is entirely ignored by CCID-3 and CCID-4,
>  * Ack Ratio currently doesn't work in CCID-2 (i.e. is always set to 1);
>  * even if it would work in CCID-2, there is no point for a user to change it:
>    - Ack Ratio is constrained by cwnd (RFC 4341, 6.1.2),
>    - if Ack Ratio > cwnd, the system resorts to spurious RTO timeouts
>      (since waiting for Acks which will never arrive in this window),
>    - cwnd is not a user-configurable value.
> 
> The only reasonable place for Ack Ratio is to print it for debugging. It is
> planned to do this later on, as part of e.g. dccp_probe.
> 
> With this patch Ack Ratio is now under full control of feature negotiation:
>  * Ack Ratio is resolved as a dependency of the selected CCID;
>  * if the chosen CCID supports it (i.e. CCID = CCID-2), Ack Ratio is set to
>    the default of 2, following RFC 4340, 11.3 - "New connections start with Ack
>    Ratio 2 for both endpoints";
>  * what happens then is part of another patch set, since it concerns the
>    dynamic update of Ack Ratio while the connection is in full flight.
> 
> Thanks to Tomasz Grobelny for discussion leading up to this patch.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Looks ok,

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

> ---
>  Documentation/networking/dccp.txt |    3 ---
>  include/linux/dccp.h              |    2 --
>  net/dccp/dccp.h                   |    1 -
>  net/dccp/minisocks.c              |    1 -
>  net/dccp/options.c                |    1 -
>  net/dccp/sysctl.c                 |    7 -------
>  6 files changed, 0 insertions(+), 15 deletions(-)
> 
> --- a/Documentation/networking/dccp.txt
> +++ b/Documentation/networking/dccp.txt
> @@ -125,9 +125,6 @@ send_ndp = 1
>  send_ackvec = 1
>  	Whether or not to send Ack Vector options (sec. 11.5).
>  
> -ack_ratio = 2
> -	The default Ack Ratio (sec. 11.3) to use.
> -
>  tx_ccid = 2
>  	Default CCID for the sender-receiver half-connection.
>  
> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -368,7 +368,6 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
>    * @dccpms_ccid - Congestion Control Id (CCID) (section 10)
>    * @dccpms_send_ack_vector - Send Ack Vector Feature (section 11.5)
>    * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
> -  * @dccpms_ack_ratio - Ack Ratio Feature (section 11.3)
>    * @dccpms_pending - List of features being negotiated
>    * @dccpms_conf -
>    */
> @@ -378,7 +377,6 @@ struct dccp_minisock {
>  	__u8			dccpms_tx_ccid;
>  	__u8			dccpms_send_ack_vector;
>  	__u8			dccpms_send_ndp_count;
> -	__u8			dccpms_ack_ratio;
>  	struct list_head	dccpms_pending;
>  	struct list_head	dccpms_conf;
>  };
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -98,7 +98,6 @@ extern int  sysctl_dccp_retries2;
>  extern int  sysctl_dccp_feat_sequence_window;
>  extern int  sysctl_dccp_feat_rx_ccid;
>  extern int  sysctl_dccp_feat_tx_ccid;
> -extern int  sysctl_dccp_feat_ack_ratio;
>  extern int  sysctl_dccp_feat_send_ack_vector;
>  extern int  sysctl_dccp_feat_send_ndp_count;
>  extern int  sysctl_dccp_tx_qlen;
> --- a/net/dccp/minisocks.c
> +++ b/net/dccp/minisocks.c
> @@ -47,7 +47,6 @@ void dccp_minisock_init(struct dccp_minisock *dmsk)
>  	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
>  	dmsk->dccpms_rx_ccid	     = sysctl_dccp_feat_rx_ccid;
>  	dmsk->dccpms_tx_ccid	     = sysctl_dccp_feat_tx_ccid;
> -	dmsk->dccpms_ack_ratio	     = sysctl_dccp_feat_ack_ratio;
>  	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
>  	dmsk->dccpms_send_ndp_count  = sysctl_dccp_feat_send_ndp_count;
>  }
> --- a/net/dccp/options.c
> +++ b/net/dccp/options.c
> @@ -26,7 +26,6 @@
>  int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
>  int sysctl_dccp_feat_rx_ccid	      = DCCPF_INITIAL_CCID;
>  int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
> -int sysctl_dccp_feat_ack_ratio	      = DCCPF_INITIAL_ACK_RATIO;
>  int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
>  int sysctl_dccp_feat_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
>  
> --- a/net/dccp/sysctl.c
> +++ b/net/dccp/sysctl.c
> @@ -41,13 +41,6 @@ static struct ctl_table dccp_default_table[] = {
>  		.proc_handler	= proc_dointvec,
>  	},
>  	{
> -		.procname	= "ack_ratio",
> -		.data		= &sysctl_dccp_feat_ack_ratio,
> -		.maxlen		= sizeof(sysctl_dccp_feat_ack_ratio),
> -		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> -	},
> -	{
>  		.procname	= "send_ackvec",
>  		.data		= &sysctl_dccp_feat_send_ack_vector,
>  		.maxlen		= sizeof(sysctl_dccp_feat_send_ack_vector),
> -- 
> 1.6.0.rc2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
