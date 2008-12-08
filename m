From: David Miller <davem@davemloft.net>
Date: Mon, 08 Dec 2008 09:18:12 +0000
Subject: Re: [PATCH 5/7] dccp: Remove obsolete parts of the old CCID
Message-Id: <20081208.011812.02391476.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1228581657-6724-6-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1228581657-6724-6-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:55 +0100

> The TX/RX CCIDs of the minisock are now redundant: similar to the Ack Vector
> case, their value equals initially that of the sysctl, but at the end of
> feature negotiation may be something different.
> 
> The old interface removed by this patch thus has been replaced by the newer
> interface to dynamically query the currently loaded CCIDs.
> 
> Also removed are the constructors for the TX CCID and the RX CCID, since the
> switch "rx <-> non-rx" is done by the handler in minisocks.c (and the handler
> is the only place in the code where CCIDs are loaded).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
