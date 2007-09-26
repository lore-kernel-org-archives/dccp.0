From: David Miller <davem@davemloft.net>
Date: Wed, 26 Sep 2007 05:39:24 +0000
Subject: Re: [PATCH 1/6] [DCCP]: Reuse ktime_get_real() calls again
Message-Id: <20070925.223924.22185946.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070922210917.GF4887@ghostprotocols.net>
In-Reply-To: <20070922210917.GF4887@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 18:09:17 -0300

> This patch reduces the number of timestamps taken in the receive path
> for each packet.
> 
> The ccid3_hc_tx_update_x() routine is called in
>  * the receive path for each CCID3-controlled packet
>  * for the nofeedback timer (if no feedback arrives during 4 RTT)
> 
> Currently, when there is no loss, each packet gets timestamped twice.
> The patch resolves this by recycling the first timestamp taken on packet
> reception for RTT sampling.
> 
> When the no_feedback_timer() is called, then the timestamp argument is
> simply set to NULL - so that ccid3_hc_tx_update_x() takes care of the logic.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied.
