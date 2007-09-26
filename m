From: David Miller <davem@davemloft.net>
Date: Wed, 26 Sep 2007 21:08:37 +0000
Subject: Re: [PATCHES 0/8][DCCP] More core work
Message-Id: <20070926.140837.118610019.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070926183900.GB10932@ghostprotocols.net>
In-Reply-To: <20070926183900.GB10932@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 15:39:00 -0300

> Hi David,
> 
> 	Please consider pulling from:
> 
> 	master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.24

Pulled, but I'd like to make a small request.

Please remove the CONFIG_IP_DCCP_CCID3_DEBUG ifdef protection
for the BUG_ON(hctx = NULL)

Either the assertion is valid, and therefore it should always
be enabled, or it isn't.

If people want to turn off BUG checks, they turn off CONFIG_BUG.

Thanks!
