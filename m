From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Feb 2010 12:12:19 +0000
Subject: [Bug-Fix][PATCH 1/2] dccp: fix bug in cache allocation
Message-Id: <1265026340-5282-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a bug introduced in commit de4ef86cfce60d2250111f34f8a084e769f23b16
("dccp: fix dccp rmmod when kernel configured to use slub", 17 Jan): the
vsnprintf used sizeof(slab_name_fmt), which became truncated to 4 bytes, since
slab_name_fmt is now a 4-byte pointer and no longer a 32-character array.

This lead to error messages such as
 FATAL: Error inserting dccp: No buffer space available

 >> kernel: [ 1456.341501] kmem_cache_create: duplicate cache cci
generated due to the truncation after the 3rd character.

Fixed for the moment by introducing a symbolic constant. Tested to fix the bug.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Neil Horman <nhorman@tuxdriver.com> 
---
 net/dccp/ccid.c |    2 +-
 net/dccp/ccid.h |    8 +++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -83,7 +83,7 @@ static struct kmem_cache *ccid_kmem_cache_create(int obj_size, char *slab_name_f
 	va_list args;
 
 	va_start(args, fmt);
-	vsnprintf(slab_name_fmt, sizeof(slab_name_fmt), fmt, args);
+	vsnprintf(slab_name_fmt, CCID_SLAB_NAME_LENGTH, fmt, args);
 	va_end(args);
 
 	slab = kmem_cache_create(slab_name_fmt, sizeof(struct ccid) + obj_size, 0,
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -19,7 +19,9 @@
 #include <linux/list.h>
 #include <linux/module.h>
 
-#define CCID_MAX 255
+/* maximum value for a CCID (RFC 4340, 19.5) */
+#define CCID_MAX		255
+#define CCID_SLAB_NAME_LENGTH	32
 
 struct tcp_info;
 
@@ -49,8 +51,8 @@ struct ccid_operations {
 	const char		*ccid_name;
 	struct kmem_cache	*ccid_hc_rx_slab,
 				*ccid_hc_tx_slab;
-	char			ccid_hc_rx_slab_name[32];
-	char			ccid_hc_tx_slab_name[32];
+	char			ccid_hc_rx_slab_name[CCID_SLAB_NAME_LENGTH];
+	char			ccid_hc_tx_slab_name[CCID_SLAB_NAME_LENGTH];
 	__u32			ccid_hc_rx_obj_size,
 				ccid_hc_tx_obj_size;
 	/* Interface Routines */
