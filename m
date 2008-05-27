From: David Miller <davem@davemloft.net>
Date: Tue, 27 May 2008 13:26:12 +0000
Subject: Re: [PATCH 3/7] [CCID-3]: Remove ccid3hc{tx,rx}_ prefixes
Message-Id: <20080527.062612.59188315.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1211877167-10995-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1211877167-10995-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:43 +0100

> This patch does the same for CCID-3 as the previous patch for CCID-2:
> 
>         s#ccid3hctx_##g;
>         s#ccid3hcrx_##g;
> 
> plus manual editing to retain consistency.
> 
> Please note: expanded the fields of the `struct tfrc_tx_info' in the hc_tx_sock,
> since using short #define identifiers is not a good idea. The only place where
> this embedded struct was used is ccid3_hc_tx_getsockopt().
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

My same comments for CCID-2 apply here, don't do this, we use
the member name prefixes to make the code easier to search
precisely.
