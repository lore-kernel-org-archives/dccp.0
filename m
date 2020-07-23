From: Christoph Hellwig <hch@lst.de>
Date: Thu, 23 Jul 2020 06:08:52 +0000
Subject: [PATCH 10/26] netfilter: remove the unused user argument to do_update_counters
Message-Id: <20200723060908.50081-11-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/bridge/netfilter/ebtables.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index fe13108af1f542..12f8929667bf43 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1242,9 +1242,8 @@ void ebt_unregister_table(struct net *net, struct ebt_table *table,
 
 /* userspace just supplied us with counters */
 static int do_update_counters(struct net *net, const char *name,
-				struct ebt_counter __user *counters,
-				unsigned int num_counters,
-				const void __user *user, unsigned int len)
+			      struct ebt_counter __user *counters,
+			      unsigned int num_counters, unsigned int len)
 {
 	int i, ret;
 	struct ebt_counter *tmp;
@@ -1299,7 +1298,7 @@ static int update_counters(struct net *net, const void __user *user,
 		return -EINVAL;
 
 	return do_update_counters(net, hlp.name, hlp.counters,
-				hlp.num_counters, user, len);
+				  hlp.num_counters, len);
 }
 
 static inline int ebt_obj_to_user(char __user *um, const char *_name,
@@ -2231,7 +2230,7 @@ static int compat_update_counters(struct net *net, void __user *user,
 		return update_counters(net, user, len);
 
 	return do_update_counters(net, hlp.name, compat_ptr(hlp.counters),
-					hlp.num_counters, user, len);
+				  hlp.num_counters, len);
 }
 
 static int compat_do_ebt_get_ctl(struct sock *sk, int cmd,
-- 
2.27.0
