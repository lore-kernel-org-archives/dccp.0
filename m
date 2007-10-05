From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 05 Oct 2007 10:25:24 +0000
Subject: Re: [PATCH 7/8]: Handle timestamps on Request/Response exchange separately
Message-Id: <200710051125.25561@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.48514@strip-the-willow>
In-Reply-To: <200709251530.48514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Arnaldo,

please disregard the earlier suggestion from below regarding ts_recent and =
feel free
to do with the structure as you see fit.=20

To me it seems that the main problems using a RFC1323-like algorithm are
 * the ts_recent field is not enough, the algorithm requires other informat=
ion (e.g. whether
   an Ack advances the send window) to deal robustly with delays, holes,=20
 * it is hard to get right (e.g. omments above tcp_ack_saw_tstamp() in tcp_=
input.c)
 * the current solution of timing both send time and Ack arrival is the sim=
plest
   and has the advantage of being responsive to receiver behaviour (as in C=
CID3).
   An additional advantage is that the current code already provides Elapse=
d Time information
   on each Ack Vector, so that dccp_sample_rtt() can be used.
   Maybe CCID2 could benefit by upgrading from jiffies to ktime_t, as this =
enables to
   better determine whether multiple losses belong to the same RTT (with 1m=
s resolution
   and Gbps speed this does not work so well).

Please can you let me know whether:

 * the outlined "struct dccp_request_sock" below is still the preferred for=
mat;
 * whether as an alternative the dreq_tstamp_{echo,time} fields can be comb=
ined, i.e.
   use a fixed member of type
	struct dccp_ts_echo {
	       	ktime_t         ts_time;
	       	__u32           ts_echo;
	};
   or similar - but without the mallocing, and with overriding each time a =
new timestamp arrives;
 * or whether a different solution is planned.

I'd need to know so that I can rework the patches and resubmit them accordi=
ngly.

=09
Quoting Gerrit Renker:
|  Quoting Arnaldo Carvalho de Melo:
|  |  I suggest it to become:
|  | =20
|  |  [acme@mica net-2.6.24]$ pahole -C dccp_request_sock net/dccp/minisock=
s.o
|  | =20
|  |  struct dccp_request_sock {
|  |  =A0 =A0 =A0 =A0 struct inet_request_sock dreq_inet_rsk; =A0 =A0/* =A0=
0 56 */
|  |  =A0 =A0 =A0 =A0 __u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_iss=
; =A0 =A0 =A0 =A0 /* 56 =A08 */
|  |  =A0 =A0 =A0 =A0 /* --- cacheline 1 boundary (64 bytes) --- */
|  |  =A0 =A0 =A0 =A0 __u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_isr=
; =A0 =A0 =A0 =A0 /* 64 =A08 */
|  |  =A0 =A0 =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dreq_servi=
ce; =A0 =A0 /* 72 =A04 */
|  |  =A0 =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_tst=
amp_echo; /* 76 =A04 */
|  |  =A0 =A0 =A0 =A0 ktime_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_tstam=
p_time; /* 80 =A08 */
|  | =20
|  |  =A0 =A0 =A0 =A0 /* size: 88, cachelines: 2 */
|  |  =A0 =A0 =A0 =A0 /* last cacheline: 24 bytes */
|  |  };
|  | =20
|  |  Humm, these minisocks are getting fat... another thing for my TODO li=
st,
|  |  request_sock::ts_recent seems to be used only by the TCP machinery, r=
ipe
|  |  for the picking....
| =20
|  I have thought about this: do you think the following solution is better=
 -
|  the difference between kmallocing and fixed is now between pointer to st=
ruct
|  and u64 (ktime_t).
| =20
| =20
|  struct dccp_request_sock {
|          struct inet_request_sock	dreq_inet_rsk;
|  	__u64                    	dreq_iss,
|  				 	dreq_isr;=20
|  	__be32                   	dreq_service;
|  #define dreq_tstamp_echo		dreq_inet_rsk.req.ts_recent=20
|  	ktime_t                  	dreq_tstamp_time;
|  };
| =20
| =20
|  The only other thing that is required is then to change the insertion ro=
utine to
| =20
|  dccp_insert_option_timestamp_echo(struct sock *sk, struct dccp_request_s=
ock *dreq,
|                                    struct sk_buff *skb);
|  				  /* when @dreq is NULL, @sk is used */
| =20
| =20
| =20
|  On another note I think that the CCID2 code could benefit from using suc=
h timestamps also, in particular
|  for high-speed networks.
