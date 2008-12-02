From: David Miller <davem@davemloft.net>
Date: Tue, 02 Dec 2008 07:34:48 +0000
Subject: Re: [PATCH 0/6] dccp: Feature negotiation - conclusion of Part II
Message-Id: <20081201.233448.32813569.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 30 Nov 2008 14:22:50 +0100

> Patch #1: Continues where the previous patch set left off, by adding
>           the insertion of feature-negotiation options onto the skb.
> Patch #2: Completes the insertion of featneg options.
> Patch #3: Logic/algorithm to actually reconcile negotiation options.
> Patch #4: Receiver support to process incoming Change L/R options. 
> Patch #5: Receiver support to process incoming Confirm R/L options.
> Patch #6: Handlers for activating successfully negotiated features.

Looks fine enough, all applied to net-next-2.6, thanks Gerrit.
