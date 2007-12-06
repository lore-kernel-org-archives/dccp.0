From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 06 Dec 2007 21:02:53 +0000
Subject: [PATCH 6/7] [CCID3]: The receiver of a half-connection does not set window counter values
Message-Id: <1196974974-31531-7-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-7-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-7-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Only the sender sets window counters [RFC 4342, sections 5 and 8.1].

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index c95dca8..5ff5aab 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -733,7 +733,6 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 		return 0;
 
 	hcrx = ccid3_hc_rx_sk(sk);
-	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_ccval_last_counter;
 
 	if (dccp_packet_without_ack(skb))
 		return 0;
-- 
1.5.3.4

