From: David Miller <davem@davemloft.net>
Date: Sat, 26 Jun 2010 04:36:43 +0000
Subject: Re: [PATCH 0/2] dccp: fix slow slow-start by symmetric Syn-RTT
Message-Id: <20100625.213643.212386410.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1277205275-5862-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1277205275-5862-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Jun 2010 13:14:33 +0200

> This changeset fixes slow startup behaviour for DCCP streaming via
> CCID-3/4 when a listening server needs to start streaming.
> 
> Patch #1: removes an unused 'sk' argument from several functions,
>           it is used by patch #2;
> 
> Patch #2: fixes the sluggish slow-start problem by taking an RTT
>           sample from the initial handshake also for listeing servers.

Both applied to net-next-2.6, thanks!
