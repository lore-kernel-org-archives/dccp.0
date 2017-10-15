From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Sun, 15 Oct 2017 18:22:10 +0000
Subject: [PATCH] net: dccp: mark expected switch fall-throughs
Message-Id: <20171015182210.GA13849@embeddedor.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that for options.c file, I placed the "fall through" comment
on its own line, which is what GCC is expecting to find.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/dccp/input.c   | 1 +
 net/dccp/options.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index fa6be97..d28d46b 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -534,6 +534,7 @@ static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
 	case DCCP_PKT_DATA:
 		if (sk->sk_state = DCCP_RESPOND)
 			break;
+		/* fall through */
 	case DCCP_PKT_DATAACK:
 	case DCCP_PKT_ACK:
 		/*
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 51cdfc3..4e40db0 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -227,8 +227,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			 * Ack vectors are processed by the TX CCID if it is
 			 * interested. The RX CCID need not parse Ack Vectors,
 			 * since it is only interested in clearing old state.
-			 * Fall through.
 			 */
+			/* fall through */
 		case DCCPO_MIN_TX_CCID_SPECIFIC ... DCCPO_MAX_TX_CCID_SPECIFIC:
 			if (ccid_hc_tx_parse_options(dp->dccps_hc_tx_ccid, sk,
 						     pkt_type, opt, value, len))
-- 
2.7.4

