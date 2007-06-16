From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:40:05 +0000
Subject: [PATCH 03/10] loss_interval: Fix timeval initialisation
Message-Id: <20070616034005.GI24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When compiling with EXTRA_CFLAGS=-W noticed that tstamp is not initialised
correctly in dccp_li_calc_first_li.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 2d203ae..9686a8d 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -829,7 +829,7 @@ static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
 	u32 x_recv, p;
 	suseconds_t rtt, delta;
-	struct timeval tstamp = { 0, };
+	struct timeval tstamp = { 0, 0 };
 	int interval = 0;
 	int win_count = 0;
 	int step = 0;
-- 
1.5.0.6

