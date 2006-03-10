From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 5/9] [SK_BUFF]: export skb_pull_rcsum
Message-Id: <11420257372423-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

*** Warning: "skb_pull_rcsum" [net/bridge/bridge.ko] undefined!
*** Warning: "skb_pull_rcsum" [net/8021q/8021q.ko] undefined!
*** Warning: "skb_pull_rcsum" [drivers/net/pppoe.ko] undefined!
*** Warning: "skb_pull_rcsum" [drivers/net/ppp_generic.ko] undefined!

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/core/skbuff.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

7c365b7e91f09e8535c7ed334b816226a58a680b
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2960c8b..c9f8784 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1816,6 +1816,8 @@ unsigned char *skb_pull_rcsum(struct sk_
 	return skb->data += len;
 }
 
+EXPORT_SYMBOL_GPL(skb_pull_rcsum);
+
 void __init skb_init(void)
 {
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
-- 
1.2.2.gd27d


