From: David Miller <davem@davemloft.net>
Date: Thu, 18 Dec 2008 05:21:51 +0000
Subject: Re: [RFCv2][PATCH] static builtin CCIDs was Re: [PATCH 2/5] dccp:
Message-Id: <20081217.212151.230224281.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20081217214608.GC14518@ghostprotocols.net>
In-Reply-To: <20081217214608.GC14518@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 17 Dec 2008 19:46:08 -0200

> So, if nobody sees any problem, please apply.
> 
> Build CCID2, because the RFC requires it to be always available, and
> CCID3 too as it is the most interesting one for VoIP, etc, together with
> the main, layer 3 agnostic, DCCP core code, so that we have a faster
> connection path by eliminating the need to always go thru the CCID
> registration lock. But keep it there, so that we can experiment with
> newer CCIDs without having to rebuild/reboot the whole kernel.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Gerrit, are you OK with this?
