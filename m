From: Jia-Ju Bai <baijiaju1990@gmail.com>
Date: Tue, 10 Apr 2018 01:15:40 +0000
Subject: [PATCH v2] net: decnet: Replace GFP_ATOMIC with GFP_KERNEL in dn_route_init
Message-Id: <1523322940-27892-1-git-send-email-baijiaju1990@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dn_route_init() is never called in atomic context.

The call chain ending up at dn_route_init() is:
[1] dn_route_init() <- decnet_init()
decnet_init() is only set as a parameter of module_init().

Despite never getting called from atomic context,
dn_route_init() calls __get_free_pages() with GFP_ATOMIC,
which does not sleep for allocation.
GFP_ATOMIC is not necessary and can be replaced with GFP_KERNEL,
which can sleep and improve the possibility of sucessful allocation.

This is found by a static analysis tool named DCNS written by myself.
And I also manually check it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
---
v2:
* Modify the description of GFP_ATOMIC in v1.
  Thank Eric for good advice.
---
 net/decnet/dn_route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 0bd3afd..59ed12a 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1898,7 +1898,7 @@ void __init dn_route_init(void)
 		while(dn_rt_hash_mask & (dn_rt_hash_mask - 1))
 			dn_rt_hash_mask--;
 		dn_rt_hash_table = (struct dn_rt_hash_bucket *)
-			__get_free_pages(GFP_ATOMIC, order);
+			__get_free_pages(GFP_KERNEL, order);
 	} while (dn_rt_hash_table = NULL && --order > 0);
 
 	if (!dn_rt_hash_table)
-- 
1.9.1

