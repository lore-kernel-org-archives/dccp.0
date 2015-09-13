From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 13 Sep 2015 12:15:27 +0000
Subject: [PATCH 34/39] dccp: drop null test before destroy functions
Message-Id: <1442146532-9100-35-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Remove unneeded NULL test.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x;
@@

-if (x != NULL)
  \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);

@@
expression x;
@@

-if (x != NULL) {
  \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
  x = NULL;
-}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/dccp/ackvec.c |   12 ++++--------
 net/dccp/ccid.c   |    3 +--
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 8349897..90f77d0 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -95,8 +95,7 @@ static struct kmem_cache *ccid_kmem_cache_create(int obj_size, char *slab_name_f
 
 static void ccid_kmem_cache_destroy(struct kmem_cache *slab)
 {
-	if (slab != NULL)
-		kmem_cache_destroy(slab);
+	kmem_cache_destroy(slab);
 }
 
 static int __init ccid_activate(struct ccid_operations *ccid_ops)
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index bd9e718..3de0d03 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -398,12 +398,8 @@ out_err:
 
 void dccp_ackvec_exit(void)
 {
-	if (dccp_ackvec_slab != NULL) {
-		kmem_cache_destroy(dccp_ackvec_slab);
-		dccp_ackvec_slab = NULL;
-	}
-	if (dccp_ackvec_record_slab != NULL) {
-		kmem_cache_destroy(dccp_ackvec_record_slab);
-		dccp_ackvec_record_slab = NULL;
-	}
+	kmem_cache_destroy(dccp_ackvec_slab);
+	dccp_ackvec_slab = NULL;
+	kmem_cache_destroy(dccp_ackvec_record_slab);
+	dccp_ackvec_record_slab = NULL;
 }

