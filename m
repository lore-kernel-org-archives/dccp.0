From: David Miller <davem@davemloft.net>
Date: Tue, 19 Sep 2006 20:13:54 +0000
Subject: Re: [PATCH 8/10]: [DCCP] CCID2: Allocate seq records on demand
Message-Id: <20060919.131354.116963148.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20060914171247.GI20651@mandriva.com>
In-Reply-To: <20060914171247.GI20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 14:12:50 -0300

> Allocate more sequence state on demand.  Each time a packet is sent out by
> CCID2, a record of it needs to be kept.  This list of records grows
> proportionally to cwnd.  Previously, the length of this list was hardcored and
> therefore the cwnd could only grow to this value (of 128).  Now, records are
> allocated on demand as necessary---cwnd may grow as it wishes.  The exceptional
> case of when memory is not available is not handled gracefully.  Perhaps, cwnd
> should be capped at that point.
> 
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

Applied, but also needed trailing whitespace fixups.

Thanks.
