From: David Miller <davem@davemloft.net>
Date: Mon, 20 Aug 2007 00:20:19 +0000
Subject: Re: [PATCH 0/15] dccp ktime_t conversion and a fix
Message-Id: <20070819.172019.84150977.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070819234821.GD24792@ghostprotocols.net>
In-Reply-To: <20070819234821.GD24792@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 20:48:21 -0300

> 	Please consider pulling from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.24.git

All applied as patches to net-2.6.24, thanks!

Since patch 1 (the gfp_any() change) is a bug fix I'll
queue that up for net-2.6 too.
