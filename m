From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Feb 2006 22:12:58 +0000
Subject: [PATCH 5/7] [DCCP]: Move dccp_hashinfo from ipv4.c to the core
Message-Id: <11407327782566-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As it is used by both ipv4 and ipv6.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ipv4.c  |    8 --------
 net/dccp/proto.c |    8 ++++++++
 2 files changed, 8 insertions(+), 8 deletions(-)

dd931ecebe9c97b8a75ac0b720c0da5f5c452408
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f087593..a7332f0 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -30,14 +30,6 @@
 #include "dccp.h"
 #include "feat.h"
 
-struct inet_hashinfo __cacheline_aligned dccp_hashinfo = {
-	.lhash_lock	= RW_LOCK_UNLOCKED,
-	.lhash_users	= ATOMIC_INIT(0),
-	.lhash_wait = __WAIT_QUEUE_HEAD_INITIALIZER(dccp_hashinfo.lhash_wait),
-};
-
-EXPORT_SYMBOL_GPL(dccp_hashinfo);
-
 static int dccp_v4_get_port(struct sock *sk, const unsigned short snum)
 {
 	return inet_csk_get_port(&dccp_hashinfo, sk, snum,
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 7ac935a..a57a8b6 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -47,6 +47,14 @@ atomic_t dccp_orphan_count = ATOMIC_INIT
 
 EXPORT_SYMBOL_GPL(dccp_orphan_count);
 
+struct inet_hashinfo __cacheline_aligned dccp_hashinfo = {
+	.lhash_lock	= RW_LOCK_UNLOCKED,
+	.lhash_users	= ATOMIC_INIT(0),
+	.lhash_wait = __WAIT_QUEUE_HEAD_INITIALIZER(dccp_hashinfo.lhash_wait),
+};
+
+EXPORT_SYMBOL_GPL(dccp_hashinfo);
+
 static struct net_protocol dccp_protocol = {
 	.handler	= dccp_v4_rcv,
 	.err_handler	= dccp_v4_err,
-- 
1.2.2.gd27d


