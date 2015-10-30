From: Tina Ruchandani <ruchandani.tina@gmail.com>
Date: Fri, 30 Oct 2015 08:24:56 +0000
Subject: [PATCH] [DCCP]: Use 64-bit timekeeping
Message-Id: <20151030082456.GA31370@tina-laptop>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch changes the use of struct timespec in
dccp_probe to use struct timespec64 instead. timespec uses a 32-bit
seconds field which will overflow in the year 2038 and beyond. timespec64
uses a 64-bit seconds field. Note that the correctness of the code isn't
changed, since the original code only uses the timestamps to compute a
small elapsed interval. This patch is part of a larger attempt to remove
instances of 32-bit timekeeping structures (timespec, timeval, time_t)
from the kernel so it is easier to identify where the real 2038 issues
are.

Signed-off-by: Tina Ruchandani <ruchandani.tina@gmail.com>
---
 net/dccp/probe.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index d8346d0..3d3fda0 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -30,6 +30,7 @@
 #include <linux/module.h>
 #include <linux/kfifo.h>
 #include <linux/vmalloc.h>
+#include <linux/time64.h>
 #include <linux/gfp.h>
 #include <net/net_namespace.h>
 
@@ -47,20 +48,20 @@ static struct {
 	struct kfifo	  fifo;
 	spinlock_t	  lock;
 	wait_queue_head_t wait;
-	struct timespec	  tstart;
+	struct timespec64 tstart;
 } dccpw;
 
 static void printl(const char *fmt, ...)
 {
 	va_list args;
 	int len;
-	struct timespec now;
+	struct timespec64 now;
 	char tbuf[256];
 
 	va_start(args, fmt);
-	getnstimeofday(&now);
+	getnstimeofday64(&now);
 
-	now = timespec_sub(now, dccpw.tstart);
+	now = timespec64_sub(now, dccpw.tstart);
 
 	len = sprintf(tbuf, "%lu.%06lu ",
 		      (unsigned long) now.tv_sec,
@@ -110,7 +111,7 @@ static struct jprobe dccp_send_probe = {
 static int dccpprobe_open(struct inode *inode, struct file *file)
 {
 	kfifo_reset(&dccpw.fifo);
-	getnstimeofday(&dccpw.tstart);
+	getnstimeofday64(&dccpw.tstart);
 	return 0;
 }
 
-- 
1.9.1

