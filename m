From: David Miller <davem@davemloft.net>
Date: Mon, 19 Jan 2009 05:40:25 +0000
Subject: Re: [PATCH 3/4] dccp: Initialisation and type-checking of feature
Message-Id: <20090118.214025.262576583.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1232184993-9927-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1232184993-9927-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Jan 2009 10:36:32 +0100

> This patch takes care of initialising and type-checking sysctls related to
> feature negotiation. Type checking is important since some of the sysctls
> now directly impact the feature-negotiation process.
> 
> The sysctls are initialised with the known default values for each feature.
> For the type-checking the value constraints from RFC 4340 are used:
> 
>  * Sequence Window uses the specified Wmin2, the maximum is ulong (4 bytes),
>    tested and confirmed that it works up to 4294967295 - for Gbps speed;
>  * Ack Ratio is between 0 .. 0xffff (2-byte unsigned integer);
>  * CCIDs are between 0 .. 255;
>  * request_retries, retries1, retries2 also between 0..255 for good measure;
>  * tx_qlen is checked to be non-negative;
>  * sync_ratelimit remains as before.
 ...
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied for 2.6.30
