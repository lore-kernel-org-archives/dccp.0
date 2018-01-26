From: David Miller <davem@davemloft.net>
Date: Fri, 26 Jan 2018 16:15:28 +0000
Subject: Re: [PATCH net v2] dccp: don't restart ccid2_hc_tx_rto_expire() if sk in closed state
Message-Id: <20180126.111528.1557408443833860633.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1516968856-900-1-git-send-email-alexey.kodanev@oracle.com>
In-Reply-To: <1516968856-900-1-git-send-email-alexey.kodanev@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Fri, 26 Jan 2018 15:14:16 +0300

> ccid2_hc_tx_rto_expire() timer callback always restarts the timer
> again and can run indefinitely (unless it is stopped outside), and after
> commit 120e9dabaf55 ("dccp: defer ccid_hc_tx_delete() at dismantle time"),
> which moved ccid_hc_tx_delete() (also includes sk_stop_timer()) from
> dccp_destroy_sock() to sk_destruct(), this started to happen quite often.
> The timer prevents releasing the socket, as a result, sk_destruct() won't
> be called.
> 
> Found with LTP/dccp_ipsec tests running on the bonding device,
> which later couldn't be unloaded after the tests were completed:
> 
>   unregister_netdevice: waiting for bond0 to become free. Usage count = 148
> 
> Fixes: 2a91aa396739 ("[DCCP] CCID2: Initial CCID2 (TCP-Like) implementation")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> ---
> 
> v2: * corrected bug origin commit id
>     * clarified commit message about sk_stop_timer()

Applied and queued up for -stable.
