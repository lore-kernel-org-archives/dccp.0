From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Date: Sat, 15 Mar 2008 18:31:07 +0000
Subject: [PATCH] DCCP: Use newer, non-deprecated __RW_LOCK_UNLOCKED macro.
Message-Id: <alpine.LFD.1.00.0803151430200.25128@localhost.localdomain>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e3f5d37..290ea15 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -46,7 +46,7 @@ atomic_t dccp_orphan_count = ATOMIC_INIT(0);
 EXPORT_SYMBOL_GPL(dccp_orphan_count);

 struct inet_hashinfo __cacheline_aligned dccp_hashinfo = {
-	.lhash_lock	= RW_LOCK_UNLOCKED,
+	.lhash_lock	= __RW_LOCK_UNLOCKED(dccp_hashinfo.lhash_lock),
 	.lhash_users	= ATOMIC_INIT(0),
 	.lhash_wait = __WAIT_QUEUE_HEAD_INITIALIZER(dccp_hashinfo.lhash_wait),
 };

====================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
====================================
