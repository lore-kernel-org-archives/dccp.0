From: David Miller <davem@davemloft.net>
Date: Mon, 17 Nov 2008 06:53:10 +0000
Subject: Re: [PATCH 2/5] dccp: Deprecate old setsockopt framework
Message-Id: <20081116.225310.261827389.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:16 +0100

> The previous setsockopt interface, which passed socket options via struct
> dccp_so_feat, is complicated/difficult to use. Continuing to support it leads to
> ugly code since the old approach did not distinguish between NN and SP values.
> 
> This patch removes the old setsockopt interface and replaces it with two new
> functions to register NN/SP values for feature negotiation. 
> These are essentially wrappers around the internal __feat_register functions,
> with checking added to avoid
> 
>  * wrong usage (type);
>  * changing values while the connection is in progress.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, I'll trust your judgment that we can get away with this...

But you have to understand that this is something you should think
about never doing again.  User interfaces are never "oops sorry, we
misdesigned that, we'll just take it away and emit some warning,
fix your app"  Once it's out there, you gotta support it forever.

