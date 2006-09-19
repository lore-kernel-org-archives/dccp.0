From: David Miller <davem@davemloft.net>
Date: Tue, 19 Sep 2006 20:16:50 +0000
Subject: Re: [PATCH 10/10]: [DCCP] CCID2: Add helper functions for changing
Message-Id: <20060919.131650.122062156.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20060914171433.GL20651@mandriva.com>
In-Reply-To: <20060914171433.GL20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 14:14:33 -0300

> Introduce methods which manipulate interesting congestion control state such as
> pipe and rtt estimate.  This is useful for people wishing to monitor the
> variables of CCID and instrument the code [perhaps using Kprobes].  Personally,
> I am a fan of encapsulation---that justifies this change =D.
> 
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

Trailing whitespace, again.  It seems to proliferate into any
new code blocks written by Andrea.  Please fix this stuff up,
you can even automate is by running:

	git apply --check --whitespace=error-all $(DIFF)

over patches, which I've mentioned many times before.

Anyways, fixed up and applied, thanks.
