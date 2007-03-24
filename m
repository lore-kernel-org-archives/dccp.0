From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 24 Mar 2007 13:06:52 +0000
Subject: [2.6 patch] make dccp_write_xmit_timer() static again
Message-Id: <20070324130652.GJ752@stusta.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_write_xmit_timer() needlessly became global.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/dccp/dccp.h  |    1 -
 net/dccp/timer.c |    2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

--- linux-2.6.21-rc4-mm1/net/dccp/dccp.h.old	2007-03-23 23:39:37.000000000 +0100
+++ linux-2.6.21-rc4-mm1/net/dccp/dccp.h	2007-03-23 23:39:58.000000000 +0100
@@ -191,7 +191,6 @@
 			   const enum dccp_pkt_type pkt_type);
 
 extern void dccp_write_xmit(struct sock *sk, int block);
-extern void dccp_write_xmit_timer(unsigned long data);
 extern void dccp_write_space(struct sock *sk);
 
 extern void dccp_init_xmit_timers(struct sock *sk);
--- linux-2.6.21-rc4-mm1/net/dccp/timer.c.old	2007-03-23 23:40:07.000000000 +0100
+++ linux-2.6.21-rc4-mm1/net/dccp/timer.c	2007-03-23 23:40:14.000000000 +0100
@@ -262,7 +262,7 @@
 }
 
 /* Transmit-delay timer: used by the CCIDs to delay actual send time */
-void dccp_write_xmit_timer(unsigned long data)
+static void dccp_write_xmit_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
 	struct dccp_sock *dp = dccp_sk(sk);

