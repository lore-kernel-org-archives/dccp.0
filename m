From: Dan Carpenter <dan.carpenter@linaro.org>
Date: Wed, 26 Jul 2023 10:47:02 +0000
Subject: [PATCH net] dccp: Allocate enough data in ccid_get_builtin_ccids()
Message-Id: <35ed2523-49ee-4e2b-b50d-38508f74f93f@moroto.mountain>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is allocating the ARRAY_SIZE() instead of the number of bytes.  The
array size is 1 or 2 depending on the .config and it should allocate
8 or 16 bytes instead.

Fixes: ddebc973c56b ("dccp: Lockless integration of CCID congestion-control plugins")
Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
---
 net/dccp/ccid.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 6beac5d348e2..9067958d3857 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -48,7 +48,8 @@ bool ccid_support_check(u8 const *ccid_array, u8 array_len)
  */
 int ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len)
 {
-	*ccid_array = kmalloc(ARRAY_SIZE(ccids), gfp_any());
+	*ccid_array = kmalloc_array(ARRAY_SIZE(ccids), sizeof(*ccid_array),
+				    gfp_any());
 	if (*ccid_array = NULL)
 		return -ENOBUFS;
 
-- 
2.39.2
