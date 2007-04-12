From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:17:51 +0000
Subject: [PATCH 27/29] Receiver does not set CCVal
Message-Id: <20070412211751.GB21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes an unnecessary statement, since the receiver of a half-connection
does not set window counter values: as specified in RFCs 3448 and 4342,
the sender provides the RTT estimates to the receiver [RFC 3448, 3.2.1], which
in the particular case of CCID3 means that only the sender sets window counters
[RFC 4342, sections 5 and 8.1].

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 6b1cc1b..e7d2b62 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -792,8 +792,6 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
 
-	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_ccval_last_counter;
-
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-- 
1.5.0.6

