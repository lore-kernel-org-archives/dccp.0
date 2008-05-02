From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 02 May 2008 22:11:53 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <200805030011.53490.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080502202242.74967BC4D@poczta.oswiecenia.net>
In-Reply-To: <20080502202242.74967BC4D@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Friday 02 of May 2008, Gerrit Renker napisa=B3:
> | --- a/net/dccp/proto.c
> | +++ b/net/dccp/proto.c
> | @@ -719,13 +722,21 @@ static int dccp_msghdr_parse(struct msghdr *msg,
> | __u32 **priority) continue;
> |
> |  		switch (cmsg->cmsg_type) {
> | +		/*
> | +		 * Assign the (opaque) qpolicy priority value to skb->priority
> | +		 *
> | +		 * We are overloading this skb field for use with the qpolicy
> | +		 * subystem. The skb->priority is normally used for the
> | +		 * SO_PRIORITY option, which is initialised from sk_priority
> | +		 * Since the assignment of sk_priority to skb->priority happens
> | +		 * later (on layer 3), we overload this field for use with
> | +		 * queueing priorities as long as the skb is on layer 4.
> | +		 */
> |  		case DCCP_SCM_PRIORITY:
> |  			if (cmsg->cmsg_len !=3D CMSG_LEN(sizeof(__u32)))
> |  				return -EINVAL;
> | -			*priority =3D (__u32 *)CMSG_DATA(cmsg);
> | +			skb->priority =3D *(__u32 *)CMSG_DATA(cmsg);
> |  			break;
> | -		default:
> | -			return -EINVAL;
> |  		}
> |  	}
> |  	return 0;
>
> It should thrown an (EINVAL) error if the user supplied a wrong parameter=
 -
> this function only checks for socket level SOL_DCCP and so if a wrong
> SCM_xxx is passed, it is an error.
>
I deleted those two lines on purpose. If the kernel cannot understand given=
=20
DCCP_SCM_xxx then the application may have been written for newer kernel. F=
or=20
example if application will specify DCCP_SCM_TIMEOUT and kernel does not=20
understand it the application can still run without problems. It just won't=
=20
be that effective.

Maybe there are cases when all DCCP_SCM_xxx must be understood by kernel. F=
or=20
such cases we could have something like setsockopt(MUST_UNDERSTAND_CMSG),=20
would that be ok?

> With regard to the typecast, I found that such typecasts sometimes lead to
> alignment errors, i.e. would require to use get_unaligned() (compare
> e.g.	ccid3_hc_tx_parse_options() where this happened before using
> get_unaligned()).
>
The CMSG_DATA() macro seems to take care of alignment, doesn't it?

> | @@ -739,15 +750,11 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock
> | *sk, struct msghdr *msg, const int noblock =3D flags & MSG_DONTWAIT;
> |  	struct sk_buff *skb;
> |  	int rc, size;
> | -	__u32 *pprio =3D NULL;
> |  	long timeo;
> |
> |  	if (len > dp->dccps_mss_cache)
> |  		return -EMSGSIZE;
> |
> | -	if (dccp_msghdr_parse(msg, &pprio))
> | -		return -EINVAL;
> | -
> |  	lock_sock(sk);
> |
> |  	if (dccp_qpolicy_full(sk)) {
>
> The reason that it was placed here is that if the user supplies a wrong
> parameter, the socket is first locked, then an skb is allocated, and
> only at this late stage it is discovered that dccp_msghdr_parse() found
> an invalid value.
>
While it is possible that data passed from userspace will be incorrect it w=
ill=20
happen very rarely. I mean in correctly written applications the data passe=
d=20
to dccp_sendmsg will be 100% correct. Otherwise the user wouldn't use the=20
application, would (s)he? There is no need to optimize code for error=20
conditions (unless it may lead to DoS, but I doubt it).

> I can see what you are trying to do, and there is a good idea in it: we
> could get rid of the requirement to use skb->fields by
>
>  1. declaring a
>
>     struct dccp_qpolicy_args {
> 	    	__s8	priority;	/* -127 .. 128 as in older  version */
> 		struct timeval timeout;
> 		/* ... other fields, or maybe even arranged as union */
>     };
>
>  2. in dccp_sendmsg(), call
>
>     struct dccp_qpolicy_args qp_args;
>
>     // ...
>     if (dccp_msghdr_parse(msg, &pprio, &qp_args))
> 		return -EINVAL;
>
>  3. dccp_msghdr_parse() fills in default values as in your approach here
>     (could use a simple memset() to start this)
>
>  4. then at the bottom of dccp_sendmsg(), the struct is passed on to
>
>     dccp_qpolicy_push(sk, skb, &qp_args);
>
>
> Of course, it means a little more work since all xxx_push() routines
> need to have a qpolicy_args argument. But the advantage that I see is
> that this gives the extensibility (and that reoccurred in your comments)
> plus it is clearer (no hidden overloading of skb fields).
>
> Maybe I missed something?
>
I'm not sure if it's not a bit over-designed approach. But apart from that =
I=20
have nothing against it.

One question: what should xxx_push() do with this additional argument? Stor=
e=20
it as whole (note that we don't have room in skb->cb) or rewrite individual=
=20
fields of dccp_qpolicy_args to fields of skb (like:
skb->priority =3D qp_args->priority;
)?
--=20
Regards,
Tomasz Grobelny
