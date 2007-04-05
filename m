From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:33:13 +0000
Subject: [PATCH 2/43]: Receiver does not set CCVal
Message-Id: <200704051633.13313@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Receiver does not set CCVal

This removes an unnecessary statement, since the receiver of a half-connection
does not set window counter values: as specified in RFCs 3448 and 4342,
the sender provides the RTT estimates to the receiver [RFC 3448, 3.2.1], which
in the particular case of CCID3 means that only the sender sets window counters
[RFC 4342, sections 5 and 8.1].

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    2 --
 1 file changed, 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -792,8 +792,6 @@ static int ccid3_hc_rx_insert_options(st
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
 
-	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_ccval_last_counter;
-
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
