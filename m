From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:17:42 +0000
Subject: [PATCH 26/29] Modulo-16 arithmetic for window counters
Message-Id: <20070412211742.GA21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This implements modulo-16 arithmetic which is needed to compare
the 4-bit CCID 3 window counter (CCVal) values; it respects
circular wraparound and returns a-b mod 16.

Implemented as a macro, since required in several places.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c              |    4 +---
 net/dccp/ccids/lib/packet_history.c |    4 +---
 net/dccp/ccids/lib/packet_history.h |    3 ++-
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 428aa92..6b1cc1b 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -841,9 +841,7 @@ static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
 				step = 1;
 				break;
 			case 1:
-				interval = win_count - entry->dccphrx_ccval;
-				if (interval < 0)
-					interval += TFRC_WIN_COUNT_LIMIT;
+				interval = SUB16(win_count, entry->dccphrx_ccval);
 				if (interval > 4)
 					goto found;
 				break;
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 02bf58f..13cae61 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -291,9 +291,7 @@ void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 					win_count = entry->dccphrx_ccval;
 					break;
 				case 2:
-					tmp = win_count - entry->dccphrx_ccval;
-					if (tmp < 0)
-						tmp += TFRC_WIN_COUNT_LIMIT;
+					tmp = SUB16(win_count, entry->dccphrx_ccval);
 					if (tmp > TFRC_WIN_COUNT_PER_RTT + 1) {
 						/*
 						 * We have found a packet older
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 78ef50f..9a27665 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -47,7 +47,8 @@
 #define TFRC_RECV_NUM_LATE_LOSS	 3
 
 #define TFRC_WIN_COUNT_PER_RTT	 4
-#define TFRC_WIN_COUNT_LIMIT	16
+/* Subtraction a-b modulo-16, respects circular wrap-around */
+#define SUB16(a, b) (((a) + 16 - (b)) & 0xF)
 
 /*
  * 	Transmitter History data structures and declarations
-- 
1.5.0.6

