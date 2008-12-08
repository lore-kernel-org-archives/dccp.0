From: David Miller <davem@davemloft.net>
Date: Mon, 08 Dec 2008 09:15:35 +0000
Subject: Re: [PATCH 1/7] dccp: Integration of dynamic feature activation -
Message-Id: <20081208.011535.209538564.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1228581657-6724-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1228581657-6724-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:51 +0100

> This first patch out of three replaces the hardcoded default settings with
> initialisation code for the dynamic feature negotiation.
> 
> The patch also ensures that the client feature-negotiation queue is flushed
> only when entering the OPEN state.
> 
> Since confirmed Change options are removed as soon as they are confirmed
> (in the DCCP-Response), this ensures that Confirm options are retransmitted.
> 
> Note on retransmitting Confirm options:
> ---------------------------------------
> Implementation experience showed that it is necessary to retransmit Confirm
> options. Thanks to Leandro Melo de Sales who reported a bug in an earlier
> revision of the patch set, resulting from not retransmitting these options.
> 
> As long as the client is in PARTOPEN, it needs to retransmit the Confirm
> options for the Change options received on the DCCP-Response from the server.
> 
> Otherwise, if the packet containing the Confirm options gets dropped in the
> network, the connection aborts due to undefined feature negotiation state.
> 
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
