From: David Miller <davem@davemloft.net>
Date: Mon, 17 Nov 2008 06:53:56 +0000
Subject: Re: [PATCH 3/5] dccp: Feature negotiation for
Message-Id: <20081116.225356.220374266.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1226751079-15019-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1226751079-15019-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:17 +0100

> This provides feature negotiation for server minimum checksum coverage
> which so far has been missing.
> 
> Since sender/receiver coverage values range only from 0...15, their
> type has also been reduced in size from u16 to u4.
> 
> Feature-negotiation options are now generated for both sender and receiver
> coverage, i.e. when the peer has `forgotten' to enable partial coverage
> then feature negotiation will automatically enable (negotiate) the partial
> coverage value for this connection.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
