From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 23 Oct 2007 22:51:37 +0000
Subject: [PATCH][DCCP 1/1] Implement SIOCINQ/FIONREAD
Message-Id: <20071023225137.GA6371@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Just like UDP.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Leandro Melo de Sales <leandroal@gmail.com>

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index cc9bf1c..723c29e 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -26,6 +26,7 @@
 #include <net/sock.h>
 #include <net/xfrm.h>
 
+#include <asm/ioctls.h>
 #include <asm/semaphore.h>
 #include <linux/spinlock.h>
 #include <linux/timer.h>
@@ -377,9 +378,37 @@ unsigned int dccp_poll(struct file *file, struct socket *sock,
 EXPORT_SYMBOL_GPL(dccp_poll);
 
 int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg)
-{
-	dccp_pr_debug("entry\n");
-	return -ENOIOCTLCMD;
+{	
+	int rc = -ENOTCONN;
+
+	lock_sock(sk);
+
+	if (sk->sk_state = DCCP_LISTEN)
+		goto out;
+
+	switch (cmd) {
+	case SIOCINQ: {
+		struct sk_buff *skb;
+		unsigned long amount = 0;
+
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb != NULL) {
+			/*
+			 * We will only return the amount of this packet since
+			 * that is all that will be read.
+			 */
+			amount = skb->len;
+		}
+		rc = put_user(amount, (int __user *)arg);
+	}
+		break;
+	default:
+		rc = -ENOIOCTLCMD;
+		break;
+	}
+out:
+	release_sock(sk);
+	return rc;
 }
 
 EXPORT_SYMBOL_GPL(dccp_ioctl);
