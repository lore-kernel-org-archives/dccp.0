From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Fri, 04 Aug 2006 14:41:38 +0000
Subject: Re: [PATCH 1/1] CCID2: Experimental support for tcp_congestion_ops
Message-Id: <20060804144138.GA6528@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <20060804110752.GA4262@shorty.sorbonet.org>
In-Reply-To: <20060804110752.GA4262@shorty.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Aug 04, 2006 at 11:28:36AM -0300, Arnaldo Carvalho de Melo wrote:
> Keep on experimenting, this is the spirit, that is why
> tcp_congestion_ops is in inet_connection_sock, eventually I want to have

Yea I noticed that when it was too late.  The other thing to do is to abstract
the state which congestion_ops use.  It shouldn't access directly tcp's cwnd,
srtt and so on.  There should probably be a structure named something like
congestion_state which contains that information.  This way, both DCCP and TCP
can provide the relevant information in a uniform way to the congestion
algorithms.
