From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 18 Jan 2010 03:16:12 +0000
Subject: [PATCH] dccp: fix dccp rmmod when kernel configured to use slub
Message-Id: <20100118031611.GA2221@localhost.localdomain>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hey all-
	I was tinkering with dccp recently and noticed that I BUG halted the
kernel when I rmmod-ed the dccp module.  The bug halt occured because the page
that I passed to kfree failed the PageCompound and PageSlab test in the slub
implementation of kfree.  I tracked the problem down to the following set of
events:

1) dccp, unlike all other uses of kmem_cache_create, allocates a string
dynamically when registering a slab cache.  This allocated string is freed when
the cache is destroyed.

2) Normally, (1) is not an issue, but when Slub is in use, it is possible that
caches are 'merged'.  This process causes multiple caches of simmilar
configuration to use the same cache data structure.  When this happens, the new
name of the cache is effectively dropped.

3) (2) results in kmem_cache_name returning an ambigous value (i.e.
ccid_kmem_cache_destroy, which uses this fuction to retrieve the name pointer
for freeing), is no longer guaranteed that the string it assigned is what is
returned. 

4) If such merge event occurs, ccid_kmem_cache_destroy frees the wrong pointer,
which trips over the BUG in the slub implementation of kfree (since its likely
not a slab allocation, but rather a pointer into the static string table
section.

So, what to do about this.  At first blush this is pretty clearly a leak in the
information that slub owns, and as such a slub bug.  Unfortunately, theres no
really good way to fix it, without exposing slub specific implementation details
to the generic slab interface.  Also, even if we could fix this in slub cleanly,
I think the RCU free option would force us to do lots of string duplication, not
only in slub, but in every slab allocator.  As such, I'd like to propose this
solution.  Basically, I just move the storage for the kmem cache name to the
ccid_operations structure.  In so doing, we don't have to do the kstrdup or
kfree when we allocate/free the various caches for dccp, and so we avoid the
problem, by storing names with static memory, rather than heap, the way all
other calls to kmem_cache_create do.

I've tested this out myself here, and it solves the problem quite well.

Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 ccid.c |   18 +++++-------------
 ccid.h |    2 ++
 2 files changed, 7 insertions(+), 13 deletions(-)


diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index f3e9ba1..57dfb9c 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -77,34 +77,24 @@ int ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
 	return err;
 }
 
-static struct kmem_cache *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
+static struct kmem_cache *ccid_kmem_cache_create(int obj_size, char *slab_name_fmt, const char *fmt,...)
 {
 	struct kmem_cache *slab;
-	char slab_name_fmt[32], *slab_name;
 	va_list args;
 
 	va_start(args, fmt);
 	vsnprintf(slab_name_fmt, sizeof(slab_name_fmt), fmt, args);
 	va_end(args);
 
-	slab_name = kstrdup(slab_name_fmt, GFP_KERNEL);
-	if (slab_name = NULL)
-		return NULL;
-	slab = kmem_cache_create(slab_name, sizeof(struct ccid) + obj_size, 0,
+	slab = kmem_cache_create(slab_name_fmt, sizeof(struct ccid) + obj_size, 0,
 				 SLAB_HWCACHE_ALIGN, NULL);
-	if (slab = NULL)
-		kfree(slab_name);
 	return slab;
 }
 
 static void ccid_kmem_cache_destroy(struct kmem_cache *slab)
 {
-	if (slab != NULL) {
-		const char *name = kmem_cache_name(slab);
-
+	if (slab != NULL)
 		kmem_cache_destroy(slab);
-		kfree(name);
-	}
 }
 
 static int ccid_activate(struct ccid_operations *ccid_ops)
@@ -113,6 +103,7 @@ static int ccid_activate(struct ccid_operations *ccid_ops)
 
 	ccid_ops->ccid_hc_rx_slab  			ccid_kmem_cache_create(ccid_ops->ccid_hc_rx_obj_size,
+					       ccid_ops->ccid_hc_rx_slab_name,
 					       "ccid%u_hc_rx_sock",
 					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_rx_slab = NULL)
@@ -120,6 +111,7 @@ static int ccid_activate(struct ccid_operations *ccid_ops)
 
 	ccid_ops->ccid_hc_tx_slab  			ccid_kmem_cache_create(ccid_ops->ccid_hc_tx_obj_size,
+					       ccid_ops->ccid_hc_tx_slab_name,
 					       "ccid%u_hc_tx_sock",
 					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_tx_slab = NULL)
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index facedd2..269958b 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -49,6 +49,8 @@ struct ccid_operations {
 	const char		*ccid_name;
 	struct kmem_cache	*ccid_hc_rx_slab,
 				*ccid_hc_tx_slab;
+	char			ccid_hc_rx_slab_name[32];
+	char			ccid_hc_tx_slab_name[32];
 	__u32			ccid_hc_rx_obj_size,
 				ccid_hc_tx_obj_size;
 	/* Interface Routines */
