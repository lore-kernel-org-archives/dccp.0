From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 13:36:13 +0000
Subject: Re: [PATCH 7/8]: Handle timestamps on Request/Response exchange separately
Message-Id: <200709271436.13945@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.48514@strip-the-willow>
In-Reply-To: <200709251530.48514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  I suggest it to become:
| =20
|  [acme@mica net-2.6.24]$ pahole -C dccp_request_sock net/dccp/minisocks.o
| =20
|  struct dccp_request_sock {
|  =A0 =A0 =A0 =A0 struct inet_request_sock dreq_inet_rsk; =A0 =A0/* =A00 5=
6 */
|  =A0 =A0 =A0 =A0 __u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_iss; =
=A0 =A0 =A0 =A0 /* 56 =A08 */
|  =A0 =A0 =A0 =A0 /* --- cacheline 1 boundary (64 bytes) --- */
|  =A0 =A0 =A0 =A0 __u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_isr; =
=A0 =A0 =A0 =A0 /* 64 =A08 */
|  =A0 =A0 =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dreq_service;=
 =A0 =A0 /* 72 =A04 */
|  =A0 =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_tstamp=
_echo; /* 76 =A04 */
|  =A0 =A0 =A0 =A0 ktime_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dreq_tstamp_t=
ime; /* 80 =A08 */
| =20
|  =A0 =A0 =A0 =A0 /* size: 88, cachelines: 2 */
|  =A0 =A0 =A0 =A0 /* last cacheline: 24 bytes */
|  };
| =20
|  Humm, these minisocks are getting fat... another thing for my TODO list,
|  request_sock::ts_recent seems to be used only by the TCP machinery, ripe
|  for the picking....

I have thought about this: do you think the following solution is better -
the difference between kmallocing and fixed is now between pointer to struct
and u64 (ktime_t).


struct dccp_request_sock {
        struct inet_request_sock	dreq_inet_rsk;
	__u64                    	dreq_iss,
				 	dreq_isr;=20
	__be32                   	dreq_service;
#define dreq_tstamp_echo		dreq_inet_rsk.req.ts_recent=20
	ktime_t                  	dreq_tstamp_time;
};


The only other thing that is required is then to change the insertion routi=
ne to

dccp_insert_option_timestamp_echo(struct sock *sk, struct dccp_request_sock=
 *dreq,
                                  struct sk_buff *skb);
				  /* when @dreq is NULL, @sk is used */



On another note I think that the CCID2 code could benefit from using such t=
imestamps also, in particular
for high-speed networks.
