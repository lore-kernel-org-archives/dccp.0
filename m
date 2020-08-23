From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 23 Aug 2020 01:07:13 +0000
Subject: [PATCH] net: dccp: delete repeated words
Message-Id: <20200823010713.4728-1-rdunlap@infradead.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Drop duplicated words in /net/dccp/.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jakub Kicinski <kuba@kernel.org>
---
 net/dccp/ackvec.c |    2 +-
 net/dccp/ipv4.c   |    2 +-
 net/dccp/timer.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

--- linux-next-20200821.orig/net/dccp/ackvec.c
+++ linux-next-20200821/net/dccp/ackvec.c
@@ -274,7 +274,7 @@ void dccp_ackvec_input(struct dccp_ackve
 /**
  * dccp_ackvec_clear_state  -  Perform house-keeping / garbage-collection
  * This routine is called when the peer acknowledges the receipt of Ack Vectors
- * up to and including @ackno. While based on on section A.3 of RFC 4340, here
+ * up to and including @ackno. While based on section A.3 of RFC 4340, here
  * are additional precautions to prevent corrupted buffer state. In particular,
  * we use tail_ackno to identify outdated records; it always marks the earliest
  * packet of group (2) in 11.4.2.
--- linux-next-20200821.orig/net/dccp/ipv4.c
+++ linux-next-20200821/net/dccp/ipv4.c
@@ -731,7 +731,7 @@ int dccp_invalid_packet(struct sk_buff *
 		return 1;
 	}
 	/*
-	 * If P.Data Offset is too too large for packet, drop packet and return
+	 * If P.Data Offset is too large for packet, drop packet and return
 	 */
 	if (!pskb_may_pull(skb, dccph_doff * sizeof(u32))) {
 		DCCP_WARN("P.Data Offset(%u) too large\n", dccph_doff);
--- linux-next-20200821.orig/net/dccp/timer.c
+++ linux-next-20200821/net/dccp/timer.c
@@ -85,7 +85,7 @@ static void dccp_retransmit_timer(struct
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	/*
-	 * More than than 4MSL (8 minutes) has passed, a RESET(aborted) was
+	 * More than 4MSL (8 minutes) has passed, a RESET(aborted) was
 	 * sent, no need to retransmit, this sock is dead.
 	 */
 	if (dccp_write_timeout(sk))
