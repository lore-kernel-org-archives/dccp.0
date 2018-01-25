From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Thu, 25 Jan 2018 17:43:57 +0000
Subject: [PATCH net] dccp: don't restart ccid2_hc_tx_rto_expire() if sk in closed state
Message-Id: <1516902237-17339-1-git-send-email-alexey.kodanev@oracle.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

ccid2_hc_tx_rto_expire() timer callback always restarts the timer
again and can run indefinitely (unless it is stopped outside), and
after commit 120e9dabaf55 ("dccp: defer ccid_hc_tx_delete() at
dismantle time"), which moved sk_stop_timer() to sk_destruct(),
this started to happen quite often. The timer prevents releasing
the socket, as a result, sk_destruct() won't be called.

Found with LTP/dccp_ipsec tests running on the bonding device,
which later couldn't be unloaded after the tests were completed:

  unregister_netdevice: waiting for bond0 to become free. Usage count = 148

Fixes: 120e9dabaf55 ("dccp: defer ccid_hc_tx_delete() at dismantle time")
Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 net/dccp/ccids/ccid2.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 1c75cd1..92d016e 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -140,6 +140,9 @@ static void ccid2_hc_tx_rto_expire(struct timer_list *t)
 
 	ccid2_pr_debug("RTO_EXPIRE\n");
 
+	if (sk->sk_state = DCCP_CLOSED)
+		goto out;
+
 	/* back-off timer */
 	hc->tx_rto <<= 1;
 	if (hc->tx_rto > DCCP_RTO_MAX)
-- 
1.7.1

