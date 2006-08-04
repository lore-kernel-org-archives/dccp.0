From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 04 Aug 2006 14:28:36 +0000
Subject: Re: [PATCH 1/1] CCID2: Experimental support for tcp_congestion_ops
Message-Id: <44D35994.3020905@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <20060804110752.GA4262@shorty.sorbonet.org>
In-Reply-To: <20060804110752.GA4262@shorty.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Andrea Bittau wrote:
> This is an experimental patch to bridge CCID2 and existing tcp congestion contrl
> algorithms.  Added support for "tcp_congestion_ops" in CCID2.  This allows for
> CCID2 to use different variants of congestion control.  The default is the RFC
> CCID2, named with much originality, "ccid2".
> 
> I added support for a "tcp adaptor" which allows existing tcp algorithms to be
> used withing CCID2.  They may be selected by asking for "tcp_name", where name
> is "reno", "vegas", etc.
> 
> The following TCP algorithms are believed to work [at least partially] with
> appropriate byte counting turned off:
> bic, compound, cubic, highspeed, htcp, reno, scalable, vegas, veno.
> These don't seem to work properly [I haven't added full support yet]:
> hybla, lp, westwood.
> 
> This patch is mainly an RFC.  If people seem to like the idea, I can work on
> making the patch look good.

Keep on experimenting, this is the spirit, that is why
tcp_congestion_ops is in inet_connection_sock, eventually I want to have
it renamed to congestion_ops, and your experiments will help in
diagnosing whatever change in the existing abstractions is needed for us
to get closer to this goal :-)

- Arnaldo
