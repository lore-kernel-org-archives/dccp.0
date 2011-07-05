From: David Miller <davem@davemloft.net>
Date: Tue, 05 Jul 2011 00:55:44 +0000
Subject: Re: net-next-2.6 [PATCH 0/6] dccp: several long-tested updates
Message-Id: <20110704.175544.2071886036329199005.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1309806079-21604-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1309806079-21604-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon,  4 Jul 2011 13:01:13 -0600

> This set contains several minor fixes and CWV for CCID-2.
> 
>   Patch #1: fixes several issues in slow-path input processing.
>   Patch #2: refactors common pattern (queueing + cloning) into the same function.
>   Patch #3: straightens cosmetics of info message appearing in logs.
>   Patch #4: puts frequently used CCID-2 inline function into header file. 
>   Patch #5: reuses existing function to test for data packets in CCID-2.
>   Patch #6: implements congestion window validation (RFC 2861) in CCID-2.
> 
> This set is also available for today's net-next-2.6 at
> 
> 	git://eden-feed.erg.abdn.ac.uk/net-next-2.6   ==>   subtree "dccp"

Pulled, thanks Gerrit.
