From: David Miller <davem@davemloft.net>
Date: Fri, 19 Dec 2008 03:15:34 +0000
Subject: Re: [RFCv2][PATCH] static builtin CCIDs was Re: [PATCH 2/5] dccp:
Message-Id: <20081218.191534.194793981.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20081217214608.GC14518@ghostprotocols.net>
In-Reply-To: <20081217214608.GC14518@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 18 Dec 2008 06:33:49 +0100

> | > Build CCID2, because the RFC requires it to be always available, and
> | > CCID3 too as it is the most interesting one for VoIP, etc, together with
> | > the main, layer 3 agnostic, DCCP core code, so that we have a faster
> | > connection path by eliminating the need to always go thru the CCID
> | > registration lock. But keep it there, so that we can experiment with
> | > newer CCIDs without having to rebuild/reboot the whole kernel.
> | > 
> | > Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> | 
> | Gerrit, are you OK with this?
> | 
> Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks everyone.
