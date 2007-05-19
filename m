From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sat, 19 May 2007 05:13:06 +0000
Subject: [PATCH 2/7] DCCP: Fix timeval initilisation
Message-Id: <200705191713.07405.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When compiling with EXTRA_CFLAGS=-W noticed that tstamp is not initialised
correctly in dccp_li_calc_first_li.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index 0b106e8..8360f56 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -158,7 +158,7 @@ static u32 dccp_li_calc_first_li(struct sock *sk)
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
 	u32 x_recv, p;
 	suseconds_t rtt, delta;
-	struct timeval tstamp = { 0, };
+	struct timeval tstamp = { 0, 0 };
 	int interval = 0;
 	int win_count = 0;
 	int step = 0;
