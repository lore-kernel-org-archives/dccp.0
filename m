From: David Miller <davem@davemloft.net>
Date: Tue, 21 Sep 2010 23:03:47 +0000
Subject: Re: net-next-2.6 [PATCH 0/5] dccp: miscellaneous CCID fixes and
Message-Id: <20100921.160347.193718359.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1285064938-5933-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1285064938-5933-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Sep 2010 12:28:53 +0200

> please find attached a tested set of 2 + 3 cleanup patches; 
>  * the first two affect the DCCP CCID interface in general,
>  * the last three conclude the first set of CCID-3 patches.
> 
>  Patch #1: allows the CCID option-parsing routines to see the packet type.
>  Patch #2: replaces magic CCID-specific numbers with symbolic constants.
>  Patch #3: removes a redundant CCID-3 state (thanks to Leandro Sales de Melo).
>  Patch #4: fixes several issues in computing the CCID-3 loss rate.
>  Patch #5: removes redundant CCID-3 TX 'options_received' struct.
> 
> The set has also been placed into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']
> 
> All patches have been tested and compile independently.    

All looks good, pulled, thanks Gerrit!
