From: David Miller <davem@davemloft.net>
Date: Wed, 26 Sep 2007 05:40:52 +0000
Subject: Re: [PATCH 3/6] [DCCP]: Simplify interface of dccp_sample_rtt
Message-Id: <20070925.224052.34745685.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070922210950.GH4887@ghostprotocols.net>
In-Reply-To: <20070922210950.GH4887@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 18:09:50 -0300

> The third parameter of dccp_sample_rtt now becomes useless and is removed.
> 
> Also combined the subtraction of the timestamp echo and the elapsed time.
> This is safe, since (a) presence of timestamp echo is tested first and (b)
> elapsed time is either present and non-zero or it is not set and equals 0
> due to the memset in dccp_parse_options.
> 
> To avoid measuring option-processing time, the timestamp for measuring the
> initial Request/Response RTT sample is taken directly when the function is
> called (the Linux implementation always adds a timestamp on the Request,
> so there is no loss in doing this).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied, thanks.
