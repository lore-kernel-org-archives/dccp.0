From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 12 Dec 2007 16:36:50 +0000
Subject: [PATCH 4/7] [CCID3]: Redundant debugging output / documentation
Message-Id: <1197477413-1456-5-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Each time feedback is sent two lines are printed:

	ccid3_hc_rx_send_feedback: client ... - entry
	ccid3_hc_rx_send_feedback: Interval ...usec, X_recv=..., 1/p=...

The first line is redundant and thus removed.

Further, documentation of ccid3_hc_rx_sock (capitalisation) is made consistent.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |    2 --
 net/dccp/ccids/ccid3.h |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 60fcb31..b92069b 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -685,8 +685,6 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 	ktime_t now;
 	s64 delta = 0;
 
-	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
-
 	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_TERM))
 		return;
 
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 3c33dc6..6ceeb80 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -135,9 +135,9 @@ enum ccid3_hc_rx_states {
  *
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
  *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
- *  @ccid3hcrx_p  -  current loss event rate (RFC 3448 5.4)
+ *  @ccid3hcrx_p  -  Current loss event rate (RFC 3448 5.4)
  *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @ccid3hcrx_state  -  receiver state, one of %ccid3_hc_rx_states
+ *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
-- 
1.5.3.4

