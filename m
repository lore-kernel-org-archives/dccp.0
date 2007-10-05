From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 05 Oct 2007 17:11:59 +0000
Subject: Re: [PATCH 7/8]: Handle timestamps on Request/Response exchange
Message-Id: <20071005171159.GA5776@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.48514@strip-the-willow>
In-Reply-To: <200709251530.48514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Fri, Oct 05, 2007 at 11:25:24AM +0100, Gerrit Renker escreveu:
> Arnaldo,
>=20
> please disregard the earlier suggestion from below regarding ts_recent an=
d feel free
> to do with the structure as you see fit.=20
>=20
> To me it seems that the main problems using a RFC1323-like algorithm are
>  * the ts_recent field is not enough, the algorithm requires other inform=
ation (e.g. whether
>    an Ack advances the send window) to deal robustly with delays, holes, =

>  * it is hard to get right (e.g. omments above tcp_ack_saw_tstamp() in tc=
p_input.c)
>  * the current solution of timing both send time and Ack arrival is the s=
implest
>    and has the advantage of being responsive to receiver behaviour (as in=
 CCID3).
>    An additional advantage is that the current code already provides Elap=
sed Time information
>    on each Ack Vector, so that dccp_sample_rtt() can be used.
>    Maybe CCID2 could benefit by upgrading from jiffies to ktime_t, as thi=
s enables to
>    better determine whether multiple losses belong to the same RTT (with =
1ms resolution
>    and Gbps speed this does not work so well).

CCID2 needs a lot of love and care, yes :-\

> Please can you let me know whether:
>=20
>  * the outlined "struct dccp_request_sock" below is still the preferred f=
ormat;


Please use the outlined one. I haven't checked, but if we use a struct
like in your second option (below) we can end up with struct holes on
64-bit arches.

>  * whether as an alternative the dreq_tstamp_{echo,time} fields can be co=
mbined, i.e.
>    use a fixed member of type
> 	struct dccp_ts_echo {
> 	       	ktime_t         ts_time;
> 	       	__u32           ts_echo;
> 	};
>    or similar - but without the mallocing, and with overriding each time =
a new timestamp arrives;
>  * or whether a different solution is planned.
>=20
> I'd need to know so that I can rework the patches and resubmit them accor=
dingly.
>=20
> =09
> Quoting Gerrit Renker:
> |  Quoting Arnaldo Carvalho de Melo:
> |  |  I suggest it to become:
> |  | =20
> |  |  [acme@mica net-2.6.24]$ pahole -C dccp_request_sock net/dccp/miniso=
cks.o
> |  | =20
> |  |  struct dccp_request_sock {
> |  |  =A0 =A0 =A0 =A0 struct inet_request_sock dreq_inet_rsk; =A0 =A0/* =
=A00 56 */
> |  |  =A0 =A0 =A0 =A0 __u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_i=
ss; =A0 =A0 =A0 =A0 /* 56 =A08 */
> |  |  =A0 =A0 =A0 =A0 /* --- cacheline 1 boundary (64 bytes) --- */
> |  |  =A0 =A0 =A0 =A0 __u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_i=
sr; =A0 =A0 =A0 =A0 /* 64 =A08 */
> |  |  =A0 =A0 =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dreq_ser=
vice; =A0 =A0 /* 72 =A04 */
> |  |  =A0 =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_t=
stamp_echo; /* 76 =A04 */
> |  |  =A0 =A0 =A0 =A0 ktime_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_tst=
amp_time; /* 80 =A08 */
> |  | =20
> |  |  =A0 =A0 =A0 =A0 /* size: 88, cachelines: 2 */
> |  |  =A0 =A0 =A0 =A0 /* last cacheline: 24 bytes */
> |  |  };
> |  | =20
> |  |  Humm, these minisocks are getting fat... another thing for my TODO =
list,
> |  |  request_sock::ts_recent seems to be used only by the TCP machinery,=
 ripe
> |  |  for the picking....
> | =20
> |  I have thought about this: do you think the following solution is bett=
er -
> |  the difference between kmallocing and fixed is now between pointer to =
struct
> |  and u64 (ktime_t).
> | =20
> | =20
> |  struct dccp_request_sock {
> |          struct inet_request_sock	dreq_inet_rsk;
> |  	__u64                    	dreq_iss,
> |  				 	dreq_isr;=20
> |  	__be32                   	dreq_service;
> |  #define dreq_tstamp_echo		dreq_inet_rsk.req.ts_recent=20
> |  	ktime_t                  	dreq_tstamp_time;
> |  };
> | =20
> | =20
> |  The only other thing that is required is then to change the insertion =
routine to
> | =20
> |  dccp_insert_option_timestamp_echo(struct sock *sk, struct dccp_request=
_sock *dreq,
> |                                    struct sk_buff *skb);
> |  				  /* when @dreq is NULL, @sk is used */
> | =20
> | =20
> | =20
> |  On another note I think that the CCID2 code could benefit from using s=
uch timestamps also, in particular
> |  for high-speed networks.
