From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Jan 2009 14:42:22 +0000
Subject: dccp test tree [RFC/RFT] [Patch 2/3] dccp: CCID-independent probe
Message-Id: <20090105144222.GC3773@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: Remove CCID-3 specific code from dccp_probe

This creates a function pointer to wrap CCID-specific code, since
CCID-specific code should not be mixed with the general DCCP code
(in particular when CCID-3 is disabled via Kconfig).

Resolving module dependencies did not work satisfactorily in the
current dccp_probe, so I created an explicit depdency by putting
the probe handler into output.c.

% modprobe -v dccp_probe 
insmod /lib/modules/2.6.28/kernel/net/dccp/dccp.ko 
insmod /lib/modules/2.6.28/kernel/net/dccp/dccp_probe.ko 

--> Still, there may be more elegant solutions to this: I'd welcome
    suggestions.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h        |   11 +++++++++++
 net/dccp/ccids/ccid3.c |   14 ++++++++++++++
 net/dccp/dccp.h        |    1 +
 net/dccp/output.c      |    8 ++++++++
 net/dccp/probe.c       |   29 ++++++++++++-----------------
 5 files changed, 46 insertions(+), 17 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -40,6 +40,7 @@ struct tcp_info;
  *  @ccid_hc_tx_packet_recv: implements feedback processing for the HC-sender
  *  @ccid_hc_tx_send_packet: implements the sending part of the HC-sender
  *  @ccid_hc_tx_packet_sent: does accounting for packets in flight by HC-sender
+ *  @ccid_hc_tx_probe: CCID-dependent hook for dccp_probe
  *  @ccid_hc_{r,t}x_get_info: INET_DIAG information for HC-receiver/sender
  *  @ccid_hc_{r,t}x_getsockopt: socket options specific to HC-receiver/sender
  */
@@ -70,6 +71,8 @@ struct ccid_operations {
 						  struct sk_buff *skb);
 	void		(*ccid_hc_tx_packet_sent)(struct sock *sk,
 						  unsigned int len);
+	size_t		(*ccid_hc_tx_probe)(struct sock *sk,
+					    char *buf, const size_t maxlen);
 	void		(*ccid_hc_rx_get_info)(struct sock *sk,
 					       struct tcp_info *info);
 	void		(*ccid_hc_tx_get_info)(struct sock *sk,
@@ -174,6 +177,14 @@ static inline void ccid_hc_tx_packet_sen
 		ccid->ccid_ops->ccid_hc_tx_packet_sent(sk, len);
 }
 
+static inline size_t ccid_hc_tx_probe(struct ccid *ccid, struct sock *sk,
+				      char *buf, const size_t maxlen)
+{
+	if (ccid->ccid_ops->ccid_hc_tx_probe != NULL)
+		return ccid->ccid_ops->ccid_hc_tx_probe(sk, buf, maxlen);
+	return 0;
+}
+
 static inline void ccid_hc_rx_packet_recv(struct ccid *ccid, struct sock *sk,
 					  struct sk_buff *skb)
 {
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -362,6 +362,19 @@ static void ccid3_hc_tx_packet_sent(stru
 		DCCP_CRIT("packet history - out of memory!");
 }
 
+static size_t ccid3_hc_tx_probe(struct sock *sk, char *buf, const size_t maxlen)
+{
+	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+
+	/* Specific field numbering:
+			5   6     7   8        9        10   11
+			s   rtt   p   X_calc   X_recv   X    t_ipi  */
+	return snprintf(buf, maxlen, " %d %d %d %u %u %u %d",
+			hctx->s, hctx->rtt, hctx->p, hctx->x_calc,
+			(unsigned)(hctx->x_recv >> 6),
+			(unsigned)(hctx->x >> 6), hctx->t_ipi);
+}
+
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
@@ -848,6 +861,7 @@ struct ccid_operations ccid3_ops = {
 	.ccid_hc_tx_exit	   = ccid3_hc_tx_exit,
 	.ccid_hc_tx_send_packet	   = ccid3_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	   = ccid3_hc_tx_packet_sent,
+	.ccid_hc_tx_probe	   = ccid3_hc_tx_probe,
 	.ccid_hc_tx_packet_recv	   = ccid3_hc_tx_packet_recv,
 	.ccid_hc_tx_parse_options  = ccid3_hc_tx_parse_options,
 	.ccid_hc_rx_obj_size	   = sizeof(struct ccid3_hc_rx_sock),
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -34,7 +34,6 @@
 
 #include "dccp.h"
 #include "ccid.h"
-#include "ccids/ccid3.h"
 
 static int port;
 
@@ -52,30 +51,26 @@ static struct {
 static void jdccp_write_xmit(struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = NULL;
-	struct timespec tv;
-	char buf[256];
-	int len, ccid = ccid_get_current_tx_ccid(dccp_sk(sk));
-
-	if (ccid = DCCPC_CCID3)
-		hctx = ccid3_hc_tx_sk(sk);
 
 	if (!port || ntohs(inet->dport) = port || ntohs(inet->sport) = port) {
-
-		tv  = ktime_to_timespec(ktime_sub(ktime_get(), dccpw.start));
-		len = sprintf(buf, "%lu.%09lu %pI4:%u %pI4:%u %u",
+		char buf[256];
+		struct timespec tv;
+		int len, ccid;
+
+		tv   = ktime_to_timespec(ktime_sub(ktime_get(), dccpw.start));
+		ccid = ccid_get_current_tx_ccid(dccp_sk(sk));
+		/* Basic field numbering (remainder is CCID-dependent):
+				     1         2       3       4
+				     sec.usec  source  dest    ccid */
+		len  = sprintf(buf, "%lu.%09lu %pI4:%u %pI4:%u %u",
 			       (unsigned long)tv.tv_sec,
 			       (unsigned long)tv.tv_nsec,
 			       &inet->saddr, ntohs(inet->sport),
 			       &inet->daddr, ntohs(inet->dport), ccid);
 
-		if (hctx)
-			len += sprintf(buf + len, " %d %d %d %u %u %u %d",
-			       hctx->s, hctx->rtt, hctx->p, hctx->x_calc,
-			       (unsigned)(hctx->x_recv >> 6),
-			       (unsigned)(hctx->x >> 6), hctx->t_ipi);
-
+		len += dccp_xmit_probe(sk, buf + len, sizeof(buf) - len - 1);
 		len += sprintf(buf + len, "\n");
+
 		kfifo_put(dccpw.fifo, buf, len);
 		wake_up(&dccpw.wait);
 	}
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -235,6 +235,7 @@ extern void dccp_send_sync(struct sock *
 			   const enum dccp_pkt_type pkt_type);
 
 extern void   dccp_write_xmit(struct sock *sk);
+extern size_t dccp_xmit_probe(struct sock *sk, char *buf, const size_t maxlen);
 extern void   dccp_write_space(struct sock *sk);
 extern void   dccp_flush_write_queue(struct sock *sk, long *time_budget);
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -365,6 +365,14 @@ void dccp_write_xmit(struct sock *sk)
 	}
 }
 
+size_t dccp_xmit_probe(struct sock *sk, char *buf, const size_t maxlen)
+{
+	struct ccid *tx_ccid = dccp_sk(sk)->dccps_hc_tx_ccid;
+
+	return tx_ccid = NULL ? 0 : ccid_hc_tx_probe(tx_ccid, sk, buf, maxlen);
+}
+EXPORT_SYMBOL_GPL(dccp_xmit_probe);
+
 /**
  * dccp_retransmit_skb  -  Retransmit Request, Close, or CloseReq packets
  * There are only four retransmittable packet types in DCCP:
 
