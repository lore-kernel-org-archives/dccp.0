From: David Miller <davem@davemloft.net>
Date: Tue, 07 Aug 2018 22:49:28 +0000
Subject: Re: [PATCH net v2] dccp: fix undefined behavior with 'cwnd' shift in ccid2_cwnd_restart()
Message-Id: <20180807.154928.1470634752988946729.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1533661437-26715-1-git-send-email-alexey.kodanev@oracle.com>
In-Reply-To: <1533661437-26715-1-git-send-email-alexey.kodanev@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Tue,  7 Aug 2018 20:03:57 +0300

> The shift of 'cwnd' with '(now - hc->tx_lsndtime) / hc->tx_rto' value
> can lead to undefined behavior [1].
> 
> In order to fix this use a gradual shift of the window with a 'while'
> loop, similar to what tcp_cwnd_restart() is doing.
> 
> When comparing delta and RTO there is a minor difference between TCP
> and DCCP, the last one also invokes dccp_cwnd_restart() and reduces
> 'cwnd' if delta equals RTO. That case is preserved in this change.
 ...
> Fixes: 113ced1f52e5 ("dccp ccid-2: Perform congestion-window validation")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> ---
> 
> v2: instead of checking the value with min(), use gradual shifting,
>     similar to tcp_cwnd_restart().

Applied and queued up for -stable, thanks.
