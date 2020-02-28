From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Fri, 28 Feb 2020 13:33:37 +0000
Subject: [PATCH][next] net: dccp: Replace zero-length array with flexible-array member
Message-Id: <20200228133337.GA23619@embeddedor>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The current codebase makes use of the zero-length array language
extension to the C90 standard, but the preferred mechanism to declare
variable-length types such as these ones is a flexible array member[1][2],
introduced in C99:

struct foo {
        int stuff;
        struct boo array[];
};

By making use of the mechanism above, we will get a compiler warning
in case the flexible array does not occur last in the structure, which
will help us prevent some kind of undefined behavior bugs from being
inadvertently introduced[3] to the codebase from now on.

Also, notice that, dynamic memory allocations won't be affected by
this change:

"Flexible array members have incomplete type, and so the sizeof operator
may not be applied. As a quirk of the original implementation of
zero-length arrays, sizeof evaluates to zero."[1]

This issue was found with the help of Coccinelle.

[1] https://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html
[2] https://github.com/KSPP/linux/issues/21
[3] commit 76497732932f ("cxgb3/l2t: Fix undefined behaviour")

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 include/linux/dccp.h | 2 +-
 net/dccp/ccid.h      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 6b64b6cc2175..07e547c02fd8 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -198,7 +198,7 @@ enum dccp_role {
 
 struct dccp_service_list {
 	__u32	dccpsl_nr;
-	__be32	dccpsl_list[0];
+	__be32	dccpsl_list[];
 };
 
 #define DCCP_SERVICE_INVALID_VALUE htonl((__u32)-1)
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index 70f88f2b4456..105f3734dadb 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -95,7 +95,7 @@ void ccid_cleanup_builtins(void);
 
 struct ccid {
 	struct ccid_operations *ccid_ops;
-	char		       ccid_priv[0];
+	char		       ccid_priv[];
 };
 
 static inline void *ccid_priv(const struct ccid *ccid)
-- 
2.25.0
