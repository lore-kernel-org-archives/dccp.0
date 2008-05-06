From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 May 2008 08:39:26 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <20080506083926.GA4115@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080502202242.74967BC4D@poczta.oswiecenia.net>
In-Reply-To: <20080502202242.74967BC4D@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | --- a/net/dccp/proto.c
| > | +++ b/net/dccp/proto.c
| > | @@ -719,13 +722,21 @@ static int dccp_msghdr_parse(struct msghdr *msg,
| > | __u32 **priority) continue;
| > |
| > |  		switch (cmsg->cmsg_type) {
| > | +		/*
| > | +		 * Assign the (opaque) qpolicy priority value to skb->priority
| > | +		 *
| > | +		 * We are overloading this skb field for use with the qpolicy
| > | +		 * subystem. The skb->priority is normally used for the
| > | +		 * SO_PRIORITY option, which is initialised from sk_priority
| > | +		 * Since the assignment of sk_priority to skb->priority happens
| > | +		 * later (on layer 3), we overload this field for use with
| > | +		 * queueing priorities as long as the skb is on layer 4.
| > | +		 */
| > |  		case DCCP_SCM_PRIORITY:
| > |  			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u32)))
| > |  				return -EINVAL;
| > | -			*priority = (__u32 *)CMSG_DATA(cmsg);
| > | +			skb->priority = *(__u32 *)CMSG_DATA(cmsg);
| > |  			break;
| > | -		default:
| > | -			return -EINVAL;
| > |  		}
| > |  	}
| > |  	return 0;
| >
| > It should thrown an (EINVAL) error if the user supplied a wrong parameter -
| > this function only checks for socket level SOL_DCCP and so if a wrong
| > SCM_xxx is passed, it is an error.
| >
| I deleted those two lines on purpose. If the kernel cannot understand given 
| DCCP_SCM_xxx then the application may have been written for newer kernel. For 
| example if application will specify DCCP_SCM_TIMEOUT and kernel does not 
| understand it the application can still run without problems. It just won't 
| be that effective.
| 
| Maybe there are cases when all DCCP_SCM_xxx must be understood by kernel. For 
| such cases we could have something like setsockopt(MUST_UNDERSTAND_CMSG), 
| would that be ok?
| 
In the online version of your patch (subtree `qpolicy' of the test tree)
I have added them back in for now.

By taking them out, you are robbing yourself of the possibility to
distinguish between truly invalid arguments ("EINVALs") and
incompatibilities. 

If it is really for an older kernel version, one can use something like
the statement in net/dccp/proto.c

  DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");

The main point of the perhaps a bit prolonged discussion is to avoid too
many deprecated warnings, i.e. I'd prefer that the API does not change
too often. 

On the other hand, making these changes is exactly what the test tree is for
- so that change/revert cycles and deprecated-API warnings  need not be done
later in mainline.



| > With regard to the typecast, I found that such typecasts sometimes lead to
| > alignment errors, i.e. would require to use get_unaligned() (compare
| > e.g.	ccid3_hc_tx_parse_options() where this happened before using
| > get_unaligned()).
| >
| The CMSG_DATA() macro seems to take care of alignment, doesn't it?
| 
Not sure about this: the question is how memory is accessed in the typecast

	skb->priority = *(__u32 *)CMSG_DATA(cmsg);

and how is this access aligned? Doing a similar typecast for DCCP
options (Timestamp, Timestamp Echo, Elapsed Time, CCID-3's Loss Event
and Receive Rate) caused an alignment exception on Sparc64, since (half)word
accesses need to be aligned on 2/4 byte boundaries.

I tested the above and it actually worked. Since I can't say whether this
was by accident or not, so it does seem safer to use get_unaligned().


| > | @@ -739,15 +750,11 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock
| > | *sk, struct msghdr *msg, const int noblock = flags & MSG_DONTWAIT;
| > |  	struct sk_buff *skb;
| > |  	int rc, size;
| > | -	__u32 *pprio = NULL;
| > |  	long timeo;
| > |
| > |  	if (len > dp->dccps_mss_cache)
| > |  		return -EMSGSIZE;
| > |
| > | -	if (dccp_msghdr_parse(msg, &pprio))
| > | -		return -EINVAL;
| > | -
| > |  	lock_sock(sk);
| > |
| > |  	if (dccp_qpolicy_full(sk)) {
| >
| > The reason that it was placed here is that if the user supplies a wrong
| > parameter, the socket is first locked, then an skb is allocated, and
| > only at this late stage it is discovered that dccp_msghdr_parse() found
| > an invalid value.
| >
| While it is possible that data passed from userspace will be incorrect it will 
| happen very rarely. I mean in correctly written applications the data passed 
| to dccp_sendmsg will be 100% correct. Otherwise the user wouldn't use the 
| application, would (s)he? There is no need to optimize code for error 
| conditions (unless it may lead to DoS, but I doubt it).
|
I am not religious about it - we can use either way.


| > I can see what you are trying to do, and there is a good idea in it: we
| > could get rid of the requirement to use skb->fields by
| >
| >  1. declaring a
| >
| >     struct dccp_qpolicy_args {
| > 	    	__s8	priority;	/* -127 .. 128 as in older  version */
| > 		struct timeval timeout;
| > 		/* ... other fields, or maybe even arranged as union */
| >     };
| >
| >  2. in dccp_sendmsg(), call
| >
| >     struct dccp_qpolicy_args qp_args;
| >
| >     // ...
| >     if (dccp_msghdr_parse(msg, &pprio, &qp_args))
| > 		return -EINVAL;
| >
| >  3. dccp_msghdr_parse() fills in default values as in your approach here
| >     (could use a simple memset() to start this)
| >
| >  4. then at the bottom of dccp_sendmsg(), the struct is passed on to
| >
| >     dccp_qpolicy_push(sk, skb, &qp_args);
| >
| >
| > Of course, it means a little more work since all xxx_push() routines
| > need to have a qpolicy_args argument. But the advantage that I see is
| > that this gives the extensibility (and that reoccurred in your comments)
| > plus it is clearer (no hidden overloading of skb fields).
| >
| > Maybe I missed something?
| >
| I'm not sure if it's not a bit over-designed approach. But apart from that I 
| have nothing against it.
| 
| One question: what should xxx_push() do with this additional argument? Store 
| it as whole (note that we don't have room in skb->cb) or rewrite individual 
| fields of dccp_qpolicy_args to fields of skb (like:
| skb->priority = qp_args->priority;
| )?
That is the point I missed: it is not necessary to equip all xxx_push()
routines with an extra argument, this can be done by the
dccp_qpolicy_push() routine.

The error in the above was to assume that qpolicy_args makes it no
longer necessary to use skb fields, which is not true.

I have not changed your patch other than adding the EINVAL lines and am
questioning whether this is not really over-designed. So far the
qpolicy_args is just a wrapper,

	struct qpolicy_args {
		__u32 priority;
	};


The University of Aberdeen is a charity registered in Scotland, No SC013683.

