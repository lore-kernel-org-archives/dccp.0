From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 02:28:01 +0000
Subject: [PATCH 3/7] [DCCP]: Introduce dccp_probe
Message-Id: <200609221428.02022.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds DCCP probing shamelessly ripped off from TCP probes by Stephen
Hemminger.

I've put in here support for further CCID3 variables as well.
Andrea/Arnaldo might look to extend for CCID2.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index 859e335..e2a095d 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -40,6 +40,22 @@ config IP_DCCP_DEBUG
 
 	  Just say N.
 
+config NET_DCCPPROBE
+	tristate "DCCP connection probing"
+	depends on PROC_FS && KPROBES
+	---help---
+	This module allows for capturing the changes to DCCP connection
+	state in response to incoming packets. It is used for debugging
+	DCCP congestion avoidance modules. If you don't understand
+	what was just said, you don't need it: say N.
+
+	Documentation on how to use the packet generator can be found
+	at http://linux-net.osdl.org/index.php/DccpProbe
+
+	To compile this code as a module, choose M here: the
+	module will be called dccp_probe.
+
+
 endmenu
 
 endmenu
diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index 7696e21..47b1371 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -11,6 +11,7 @@ dccp_ipv4-y := ipv4.o
 dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.o
 
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o
+obj-$(CONFIG_NET_DCCPPROBE) += dccp_probe.o
 
 dccp-$(CONFIG_SYSCTL) += sysctl.o
 
diff --git a/net/dccp/dccp_probe.c b/net/dccp/dccp_probe.c
new file mode 100644
index 0000000..4b65aad
--- /dev/null
+++ b/net/dccp/dccp_probe.c
@@ -0,0 +1,197 @@
+/*
+ * dccpprobe - Observe the DCCP flow with kprobes.
+ *
+ * The idea for this came from Werner Almesberger's umlsim
+ * Copyright (C) 2004, Stephen Hemminger <shemminger@osdl.org>
+ *
+ * Modified for DCCP from Stephen Hemminger's code
+ * Copyright (C) 2006, Ian McDonald <ian.mcdonald@jandi.co.nz>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/kprobes.h>
+#include <linux/socket.h>
+#include <linux/dccp.h>
+#include <linux/proc_fs.h>
+#include <linux/module.h>
+#include <linux/kfifo.h>
+#include <linux/vmalloc.h>
+
+#include "dccp.h"
+#include "ccid.h"
+#include "ccids/ccid3.h"
+
+MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>");
+MODULE_DESCRIPTION("DCCP snooper");
+MODULE_LICENSE("GPL");
+
+static int port = 0;
+MODULE_PARM_DESC(port, "Port to match (0=all)");
+module_param(port, int, 0);
+
+static int bufsize = 64*1024;
+MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
+module_param(bufsize, int, 0);
+
+static const char procname[] = "dccpprobe";
+
+struct {
+	struct kfifo  *fifo;
+	spinlock_t    lock;
+	wait_queue_head_t wait;
+	struct timeval tstart;
+} dccpw;
+
+static void printl(const char *fmt, ...)
+{
+	va_list args;
+	int len;
+	struct timeval now;
+	char tbuf[256];
+
+	va_start(args, fmt);
+	do_gettimeofday(&now);
+
+	now.tv_sec -= dccpw.tstart.tv_sec;
+	now.tv_usec -= dccpw.tstart.tv_usec;
+	if (now.tv_usec < 0) {
+		--now.tv_sec;
+		now.tv_usec += 1000000;
+	}
+
+	len = sprintf(tbuf, "%lu.%06lu ",
+		      (unsigned long) now.tv_sec,
+		      (unsigned long) now.tv_usec);
+	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
+	va_end(args);
+
+	kfifo_put(dccpw.fifo, tbuf, len);
+	wake_up(&dccpw.wait);
+}
+
+static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t size)
+{
+	const struct dccp_minisock *dmsk = dccp_msk(sk);
+	const struct inet_sock *inet = inet_sk(sk);
+	struct ccid3_hc_tx_sock *hctx;
+
+	if (dmsk->dccpms_tx_ccid = DCCPC_CCID3)
+		hctx = ccid3_hc_tx_sk(sk);
+	else
+		hctx = NULL;
+
+	if (port = 0 || ntohs(inet->dport) = port ||
+	    ntohs(inet->sport) = port) {
+		if (hctx)
+			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %d\n",
+			   NIPQUAD(inet->saddr), ntohs(inet->sport),
+			   NIPQUAD(inet->daddr), ntohs(inet->dport), size,
+			   hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
+			   hctx->ccid3hctx_p, hctx->ccid3hctx_t_ipi);
+		else
+			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
+			   NIPQUAD(inet->saddr), ntohs(inet->sport),
+			   NIPQUAD(inet->daddr), ntohs(inet->dport), size);
+	}
+
+	jprobe_return();
+	return 0;
+}
+
+static struct jprobe dccp_send_probe = {
+	.kp = { .addr = (kprobe_opcode_t *) &dccp_sendmsg, },
+	.entry = (kprobe_opcode_t *) &jdccp_sendmsg,
+};
+
+
+static int dccpprobe_open(struct inode * inode, struct file * file)
+{
+	kfifo_reset(dccpw.fifo);
+	do_gettimeofday(&dccpw.tstart);
+	return 0;
+}
+
+static ssize_t dccpprobe_read(struct file *file, char __user *buf,
+			     size_t len, loff_t *ppos)
+{
+	int error = 0, cnt = 0;
+	unsigned char *tbuf;
+
+	if (!buf || len < 0)
+		return -EINVAL;
+
+	if (len = 0)
+		return 0;
+
+	tbuf = vmalloc(len);
+	if (!tbuf)
+		return -ENOMEM;
+
+	error = wait_event_interruptible(dccpw.wait,
+					 __kfifo_len(dccpw.fifo) != 0);
+	if (error)
+		goto out_free;
+
+	cnt = kfifo_get(dccpw.fifo, tbuf, len);
+	error = copy_to_user(buf, tbuf, cnt);
+
+out_free:
+	vfree(tbuf);
+
+	return error ? error : cnt;
+}
+
+static struct file_operations dccpprobe_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = dccpprobe_open,
+	.read    = dccpprobe_read,
+};
+
+static __init int dccpprobe_init(void)
+{
+	int ret = -ENOMEM;
+
+	init_waitqueue_head(&dccpw.wait);
+	spin_lock_init(&dccpw.lock);
+	dccpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &dccpw.lock);
+
+	if (!proc_net_fops_create(procname, S_IRUSR, &dccpprobe_fops))
+		goto err0;
+
+	ret = register_jprobe(&dccp_send_probe);
+	if (ret)
+		goto err1;
+
+	pr_info("DCCP watch registered (port=%d)\n", port);
+	return 0;
+ err1:
+	proc_net_remove(procname);
+ err0:
+	kfifo_free(dccpw.fifo);
+	return ret;
+}
+module_init(dccpprobe_init);
+
+static __exit void dccpprobe_exit(void)
+{
+	kfifo_free(dccpw.fifo);
+	proc_net_remove(procname);
+	unregister_jprobe(&dccp_send_probe);
+
+}
+module_exit(dccpprobe_exit);
