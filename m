From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 01 Jul 2007 20:23:44 +0000
Subject: [-mm patch] make struct dccp_li_cachep static
Message-Id: <20070701202344.GX10869@stusta.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Jun 28, 2007 at 03:43:21AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.22-rc4-mm2:
>...
>  git-net.patch
>...
>  git trees
>...


Struct dccp_li_cachep can become static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/net/dccp/ccids/lib/loss_interval.c.old	2007-07-01 00:38:12.000000000 +0200
+++ linux-2.6.22-rc6-mm1/net/dccp/ccids/lib/loss_interval.c	2007-07-01 00:38:21.000000000 +0200
@@ -27,7 +27,7 @@
 	u32		 dccplih_interval;
 };
 
-struct kmem_cache *dccp_li_cachep __read_mostly;
+static struct kmem_cache *dccp_li_cachep __read_mostly;
 
 static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(const gfp_t prio)
 {

