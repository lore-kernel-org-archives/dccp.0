From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:52:40 +0000
Subject: [PATCH 13/15] [DCCP] options: convert dccp_insert_option_timestamp
Message-Id: <20070819235240.GQ24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/options.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index 95b75d8..439e25d 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -388,11 +388,7 @@ EXPORT_SYMBOL_GPL(dccp_timestamp);
 
 int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
 {
-	struct timeval tv;
-	__be32 now;
-
-	dccp_timestamp(sk, &tv);
-	now = htonl(timeval_usecs(&tv) / 10);
+	__be32 now = htonl(((suseconds_t)ktime_to_us(ktime_get_real())) / 10);
 	/* yes this will overflow but that is the point as we want a
 	 * 10 usec 32 bit timer which mean it wraps every 11.9 hours */
 
-- 
1.5.2.2

