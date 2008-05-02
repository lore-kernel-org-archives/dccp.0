From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 02 May 2008 21:23:03 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <20080502212303.GC5116@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080502202242.74967BC4D@poczta.oswiecenia.net>
In-Reply-To: <20080502202242.74967BC4D@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| dccp_msghdr_parse can now parse arbitrary DCCP_SCM_* fields and put them
| directly into skb. Now the function also sets deault values and ignores
| unknown fields. Moved clearing of used skb fields to dccp_qpolicy_pop.
| 
The clearing of the skb-fields is a very good idea and I would like to
add this to the patch. With the other parts I am having some difficulties;
there were reasons why it was done this way - comments below.

| --- a/net/dccp/proto.c
| +++ b/net/dccp/proto.c
| @@ -719,13 +722,21 @@ static int dccp_msghdr_parse(struct msghdr *msg, __u32 **priority)
|  			continue;
|  
|  		switch (cmsg->cmsg_type) {
| +		/*
| +		 * Assign the (opaque) qpolicy priority value to skb->priority
| +		 *
| +		 * We are overloading this skb field for use with the qpolicy
| +		 * subystem. The skb->priority is normally used for the
| +		 * SO_PRIORITY option, which is initialised from sk_priority
| +		 * Since the assignment of sk_priority to skb->priority happens
| +		 * later (on layer 3), we overload this field for use with
| +		 * queueing priorities as long as the skb is on layer 4.
| +		 */
|  		case DCCP_SCM_PRIORITY:
|  			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u32)))
|  				return -EINVAL;
| -			*priority = (__u32 *)CMSG_DATA(cmsg);
| +			skb->priority = *(__u32 *)CMSG_DATA(cmsg);
|  			break;
| -		default:
| -			return -EINVAL;
|  		}
|  	}
|  	return 0;
It should thrown an (EINVAL) error if the user supplied a wrong parameter - this function only 
checks for socket level SOL_DCCP and so if a wrong SCM_xxx is passed, it is an error.

With regard to the typecast, I found that such typecasts sometimes lead to alignment errors, 
i.e. would require to use get_unaligned() (compare e.g.	ccid3_hc_tx_parse_options() where this
happened before using get_unaligned()).

| @@ -739,15 +750,11 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
|  	const int noblock = flags & MSG_DONTWAIT;
|  	struct sk_buff *skb;
|  	int rc, size;
| -	__u32 *pprio = NULL;
|  	long timeo;
|  
|  	if (len > dp->dccps_mss_cache)
|  		return -EMSGSIZE;
|  
| -	if (dccp_msghdr_parse(msg, &pprio))
| -		return -EINVAL;
| -
|  	lock_sock(sk);
|  
|  	if (dccp_qpolicy_full(sk)) {
The reason that it was placed here is that if the user supplies a wrong
parameter, the socket is first locked, then an skb is allocated, and
only at this late stage it is discovered that dccp_msghdr_parse() found
an invalid value.

	/* break */

I can see what you are trying to do, and there is a good idea in it: we
could get rid of the requirement to use skb->fields by
 
 1. declaring a 

    struct dccp_qpolicy_args {
	    	__s8	priority;	/* -127 .. 128 as in older  version */
		struct timeval timeout;
		/* ... other fields, or maybe even arranged as union */
    };

 2. in dccp_sendmsg(), call
 
    struct dccp_qpolicy_args qp_args;

    // ...
    if (dccp_msghdr_parse(msg, &pprio, &qp_args))
		return -EINVAL;

 3. dccp_msghdr_parse() fills in default values as in your approach here
    (could use a simple memset() to start this)

 4. then at the bottom of dccp_sendmsg(), the struct is passed on to 

    dccp_qpolicy_push(sk, skb, &qp_args);


Of course, it means a little more work since all xxx_push() routines
need to have a qpolicy_args argument. But the advantage that I see is
that this gives the extensibility (and that reoccurred in your comments)
plus it is clearer (no hidden overloading of skb fields).

Maybe I missed something?


The University of Aberdeen is a charity registered in Scotland, No SC013683.

