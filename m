From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Fri, 26 Jan 2018 11:53:16 +0000
Subject: Re: [PATCH net] dccp: don't restart ccid2_hc_tx_rto_expire() if sk in closed state
Message-Id: <2d74c2f9-5161-4bf3-75a7-21e8d4fd24f5@oracle.com>
List-Id: <dccp.vger.kernel.org>
References: <1516902237-17339-1-git-send-email-alexey.kodanev@oracle.com>
In-Reply-To: <1516902237-17339-1-git-send-email-alexey.kodanev@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 01/25/2018 09:03 PM, Eric Dumazet wrote:
> On Thu, 2018-01-25 at 20:43 +0300, Alexey Kodanev wrote:
>> ccid2_hc_tx_rto_expire() timer callback always restarts the timer
>> again and can run indefinitely (unless it is stopped outside), and
>> after commit 120e9dabaf55 ("dccp: defer ccid_hc_tx_delete() at
>> dismantle time"), which moved sk_stop_timer() to sk_destruct(),
>> this started to happen quite often. The timer prevents releasing
>> the socket, as a result, sk_destruct() won't be called.
>>
>> Found with LTP/dccp_ipsec tests running on the bonding device,
>> which later couldn't be unloaded after the tests were completed:
>>
>>   unregister_netdevice: waiting for bond0 to become free. Usage count = 148
>>
>> Fixes: 120e9dabaf55 ("dccp: defer ccid_hc_tx_delete() at dismantle time")
>> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
>> ---
> 
> I understand your fix, but not why commit 120e9dabaf55 is bug origin.
> 
> Looks like this always had been buggy : Timer logic should have checked
> socket state from day 0.

Hi Eric,

Agree, I'll change to the initial commit id. I've added commit 120e9dabaf55
because ccid_hc_tx_delete() (and sk_stop_timer()) moved from dccp_destroy_sock()
to sk_destruct(), and only after this change the chances that the timer won't
stop increased significantly.

> 
> I did not move sk_stop_timer() to sk_destruct()
> 

ccid_hc_tx_delete() includes sk_stop_timer():


ccid_hc_tx_delete()
    ccid2_hc_tx_exit(struct sock *sk)
        sk_stop_timer(sk, &hc->tx_rtotimer);

    ccid3_hc_tx_exit(struct sock *sk)
        sk_stop_timer(sk, &hc->tx_no_feedback_timer);


Thanks,
Alexey
