From: David Miller <davem@davemloft.net>
Date: Tue, 12 Oct 2010 18:45:48 +0000
Subject: Re: net-next-2.6 [PATCH 0/6] dccp: miscellaneous fixes and helper
Message-Id: <20101012.114548.189717363.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1286860551-6809-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1286860551-6809-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 12 Oct 2010 07:15:45 +0200

>  Patch #1: fixes two problems in the DCCP  (AWL/SWL) window-size adjustment.
>  Patch #2: refactors the connect_init() function by combining related code.
>  Patch #3: removes an never-user argument from the CCID tx function.
>  Patch #4: provides a function to generalize the data-loss condition 
>            (patch originally came from the ccid-4 subtree).
>  Patch #5: schedules an Ack as carrier for a pending timestamp echo.
>  Patch #6: tidies up the format of DCCP per-connection warnings.
> 
> The set has also been placed into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

Looks good, pulled, thanks!
