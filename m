From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 28 Aug 2008 21:45:01 +0000
Subject: Re: [PATCH 15/37] dccp: Set per-connection CCIDs via socket options
Message-Id: <20080828214501.GT9193@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-16-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-16-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Aug 28, 2008 at 07:44:50PM +0200, Gerrit Renker escreveu:
> With this patch, TX/RX CCIDs can now be changed on a per-connection basis, which
> overrides the defaults set by the global sysctl variables for TX/RX CCIDs.
> 
> To make full use of this facility, the remaining patches of this patch set are
> needed, which track dependencies and activate negotiated feature values.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
>  Documentation/networking/dccp.txt |   14 ++++++++++++++
>  include/linux/dccp.h              |    5 +++++
>  net/dccp/proto.c                  |   32 ++++++++++++++++++++++++++++++++
>  3 files changed, 51 insertions(+), 0 deletions(-)
> 
> --- a/Documentation/networking/dccp.txt
> +++ b/Documentation/networking/dccp.txt
> @@ -61,6 +61,20 @@ DCCP_SOCKOPT_AVAILABLE_CCIDS is also read-only and returns the list of CCIDs
>  supported by the endpoint (see include/linux/dccp.h for symbolic constants).
>  The caller needs to provide a sufficiently large (> 2) array of type uint8_t.
>  
> +DCCP_SOCKOPT_CCID is write-only and sets both the TX and RX CCIDs at the same
> +time, combining the operation of the next two socket options. This option is
> +preferrable over the latter two, since often applications will use the same
> +type of CCID for both directions; and mixed use of CCIDs is not currently well
> +understood. This socket option takes as argument at least one uint8_t value, or
> +an array of uint8_t values, which must match available CCIDS (see above). CCIDs
> +must be registered on the socket before calling connect() or listen().
> +
> +DCCP_SOCKOPT_TX_CCID is read/write. It returns the current CCID (if set) or sets
> +the preference list for the TX CCID, using the same format as DCCP_SOCKOPT_CCID.
> +Please note that the getsockopt argument type here is `int', not uint8_t.
> +
> +DCCP_SOCKOPT_RX_CCID is analogous to DCCP_SOCKOPT_TX_CCID, but for the RX CCID.
> +
>  DCCP_SOCKOPT_SERVER_TIMEWAIT enables the server (listening socket) to hold
>  timewait state when closing the connection (RFC 4340, 8.3). The usual case is
>  that the closing server sends a CloseReq, whereupon the client holds timewait
> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -203,11 +203,16 @@ enum dccp_feature_numbers {
>  #define DCCP_SOCKOPT_SEND_CSCOV		10
>  #define DCCP_SOCKOPT_RECV_CSCOV		11
>  #define DCCP_SOCKOPT_AVAILABLE_CCIDS	12
> +#define DCCP_SOCKOPT_CCID		13
> +#define DCCP_SOCKOPT_TX_CCID		14
> +#define DCCP_SOCKOPT_RX_CCID		15
>  #define DCCP_SOCKOPT_CCID_RX_INFO	128
>  #define DCCP_SOCKOPT_CCID_TX_INFO	192
>  
>  /* maximum number of services provided on the same listening port */
>  #define DCCP_SERVICE_LIST_MAX_LEN      32
> +/* maximum number of CCID preferences that can be registered at one time */
> +#define DCCP_CCID_LIST_MAX_LEN	       16

Since this is an arbitrary lenght up to 253, it could as well be 253,
no? Or is there any other limit that I'm forgetting? :-) It may well be
that case, would have to read the RFC about how the encoding is done for
feat len, which I did some weeks ago, but...
  
>  #ifdef __KERNEL__
>  
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -505,6 +505,34 @@ static int dccp_setsockopt_cscov(struct sock *sk, int cscov, bool rx)
>  	return rc;
>  }
>  
> +static int dccp_setsockopt_ccid(struct sock *sk, int type,
> +				char __user *optval, int optlen)
> +{
> +	u8 *val;
> +	int rc = 0;
> +
> +	if (optlen < 1 || optlen > DCCP_CCID_LIST_MAX_LEN)
> +		return -EINVAL;
> +
> +	val = kmalloc(optlen, GFP_KERNEL);
> +	if (val = NULL)
> +		return -ENOMEM;
> +
> +	if (copy_from_user(val, optval, optlen))
> +		rc = -EFAULT;
> +
> +	lock_sock(sk);
> +	if (!rc && (type = DCCP_SOCKOPT_TX_CCID || type = DCCP_SOCKOPT_CCID))
> +		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 1, val, optlen);
> +

This _really_ is confusing! Why not:

	rc = -EFAULT;
	if (copy_from_user(val, optval, optlen))
		goto out;

	lock_sock(sk);
	rc = 0;
	if (type = DCCP_SOCKOPT_TX_CCID || type = DCCP_SOCKOPT_CCID)
		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 1, val, optlen);

	if (!rc && (type = DCCP_SOCKOPT_RX_CCID || type = DCCP_SOCKOPT_CCID))
		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 0, val, optlen);
	release_sock(sk);
out:
> +	kfree(val);
> +	return rc;
> +}

:-)

And even then that '0' or '1' requires one to look at what this binary
number means, we could have something like
dccp_feat_register_sp_{local,remote} perhaps, IIRC that is the is_local
parameter, no?

> +
>  static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
>  		char __user *optval, int optlen)
>  {
> @@ -519,6 +547,10 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
>  	case DCCP_SOCKOPT_CHANGE_R:
>  		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
>  		return 0;
> +	case DCCP_SOCKOPT_CCID:
> +	case DCCP_SOCKOPT_RX_CCID:
> +	case DCCP_SOCKOPT_TX_CCID:
> +		return dccp_setsockopt_ccid(sk, optname, optval, optlen);
>  	default:
>  		if (optlen < sizeof(int))
>  			return -EINVAL;
> -- 
> 1.6.0.rc2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
