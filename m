From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jan 2008 10:16:16 +0000
Subject: [PATCH 6/6] [DCCP-PROBE]: Reduce noise in output and convert to ktime_t
Message-Id: <1201515376-8280-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes the problem that dccp_probe output can grow quite large without
apparent benefit (many identical data points), creating huge files (up to
over one Gigabyte for a few minutes' test run) which are very hard to
post-process (in one instance it got so bad that gnuplot ate up all memory
plus swap).

The cause for the problem is that the kprobe is inserted into dccp_sendmsg,
which can be called in a polling-mode (whenever the TX queue is full due to
congestion-control issues, EAGAIN is returned). This creates many very
similar data points, i.e. the increase of processing time does not increase
the quality/information of the probe output.

The fix is to attach the probe to a different function -- write_xmit was
chosen since it gets called continually (both via userspace and timer);
an input-path function would stop sampling as soon as the other end stops
sending feedback.

For comparison the output file sizes for the same 20 second test
run over a lossy link:
           * before / without patch:  118   Megabytes
           * after  / with patch:       1.2 Megabytes
and there was much less noise in the output.

To allow backward compatibility with scripts that people use, the now-unused
`size' field in the output has been replaced with the CCID identifier. This
also serves for future compatibility - support for CCID2 is work in progress
(depends on the still unfinished SRTT/RTTVAR updates).

While at it, the update to ktime_t was also performed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/probe.c |   68 ++++++++++++++++++-----------------------------------
 1 files changed, 23 insertions(+), 45 deletions(-)

--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -46,77 +46,55 @@ struct {
 	struct kfifo	  *fifo;
 	spinlock_t	  lock;
 	wait_queue_head_t wait;
-	struct timeval	  tstart;
+	ktime_t		  start;
 } dccpw;
 
-static void printl(const char *fmt, ...)
-{
-	va_list args;
-	int len;
-	struct timeval now;
-	char tbuf[256];
-
-	va_start(args, fmt);
-	do_gettimeofday(&now);
-
-	now.tv_sec -= dccpw.tstart.tv_sec;
-	now.tv_usec -= dccpw.tstart.tv_usec;
-	if (now.tv_usec < 0) {
-		--now.tv_sec;
-		now.tv_usec += 1000000;
-	}
-
-	len = sprintf(tbuf, "%lu.%06lu ",
-		      (unsigned long) now.tv_sec,
-		      (unsigned long) now.tv_usec);
-	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
-	va_end(args);
-
-	kfifo_put(dccpw.fifo, tbuf, len);
-	wake_up(&dccpw.wait);
-}
-
-static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
-			 struct msghdr *msg, size_t size)
+static void jdccp_write_xmit(struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = NULL;
+	struct timespec tv;
+	char tbuf[256];
+	int len, ccid = ccid_get_current_id(dccp_sk(sk), false);
 
-	if (ccid_get_current_id(dccp_sk(sk), false) = DCCPC_CCID3)
+	if (ccid = DCCPC_CCID3)
 		hctx = ccid3_hc_tx_sk(sk);
 
-	if (port = 0 || ntohs(inet->dport) = port ||
-	    ntohs(inet->sport) = port) {
-		if (hctx)
-			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %u "
-			       "%llu %llu %d\n",
+	if (!port || ntohs(inet->dport) = port || ntohs(inet->sport) = port) {
+
+		tv  = ktime_to_timespec(ktime_sub(ktime_get(), dccpw.start));
+		len = sprintf(tbuf, "%lu.%09lu %d.%d.%d.%d:%u %d.%d.%d.%d:%u %d",
+			       (unsigned long) tv.tv_sec,
+			       (unsigned long) tv.tv_nsec,
 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
-			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
+			       NIPQUAD(inet->daddr), ntohs(inet->dport), ccid);
+
+		if (hctx)
+			len += sprintf(tbuf + len, " %d %d %d %u %llu %llu %d",
 			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
 			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
 			       hctx->ccid3hctx_x_recv >> 6,
 			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi);
-		else
-			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
-			       NIPQUAD(inet->saddr), ntohs(inet->sport),
-			       NIPQUAD(inet->daddr), ntohs(inet->dport), size);
+
+		len += sprintf(tbuf + len, "\n");
+		kfifo_put(dccpw.fifo, tbuf, len);
+		wake_up(&dccpw.wait);
 	}
 
 	jprobe_return();
-	return 0;
 }
 
 static struct jprobe dccp_send_probe = {
 	.kp	= {
-		.symbol_name = "dccp_sendmsg",
+		.symbol_name = "dccp_write_xmit",
 	},
-	.entry	= jdccp_sendmsg,
+	.entry	= jdccp_write_xmit,
 };
 
 static int dccpprobe_open(struct inode *inode, struct file *file)
 {
 	kfifo_reset(dccpw.fifo);
-	do_gettimeofday(&dccpw.tstart);
+	dccpw.start = ktime_get();
 	return 0;
 }
 
