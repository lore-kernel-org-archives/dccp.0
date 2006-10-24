From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 14:01:05 +0000
Subject: [PATCH 14/17] [DCCP]: Fix logfile overflow by Ian McDonald
Message-Id: <200610241501.05986@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This bug-fix is a re-sent from today, the patch is by Ian McDonald
and the original commit message is:

This patch fixes data being spewed into the logs continually. As the code
stood if there was a large queue and long delays timeo would go down to
zero and never get reset.

This fixes it by resetting timeo. Put constant into header as well.

Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/dccp.h   |    2 ++
 net/dccp/output.c |    8 +++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f294b89..ab0e5b1 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -61,6 +61,8 @@ #define DCCP_RESOURCE_PROBE_INTERVAL ((u
 
 #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
 
+#define DCCP_XMIT_TIMEO 30000 /* Time/msecs for blocking transmit per packet */
+
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 728255b..1478ace 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -249,8 +249,8 @@ void dccp_write_xmit(struct sock *sk, in
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
-	long timeo = 30000; 	/* If a packet is taking longer than 2 secs
-				   we have other issues */
+	long timeo = DCCP_XMIT_TIMEO; 	/* If a packet is taking longer than
+					   this we have other issues */
 
 	while ((skb = skb_peek(&sk->sk_write_queue))) {
 		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
@@ -261,8 +261,10 @@ void dccp_write_xmit(struct sock *sk, in
 				sk_reset_timer(sk, &dp->dccps_xmit_timer,
 						msecs_to_jiffies(err)+jiffies);
 				break;
-			} else
+			} else {
 				err = dccp_wait_for_ccid(sk, skb, &timeo);
+				timeo = DCCP_XMIT_TIMEO;
+			}
 			if (err) {
 				printk(KERN_CRIT "%s:err at dccp_wait_for_ccid"
 						 " %d\n", __FUNCTION__, err);
