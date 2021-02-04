From: Zheng Yongjun <zhengyongjun3@huawei.com>
Date: Thu, 04 Feb 2021 07:28:20 +0000
Subject: [PATCH net-next] dccp: Return the correct errno code
Message-Id: <20210204072820.17723-1-zhengyongjun3@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When kalloc or kmemdup failed, should return ENOMEM rather than ENOBUF.

Signed-off-by: Zheng Yongjun <zhengyongjun3@huawei.com>
---
 net/dccp/feat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 788dd629c420..4cb813bee7b4 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -371,7 +371,7 @@ static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
 		fval->sp.vec = kmemdup(val, len, gfp_any());
 		if (fval->sp.vec = NULL) {
 			fval->sp.len = 0;
-			return -ENOBUFS;
+			return -ENOMEM;
 		}
 	}
 	return 0;
-- 
2.22.0
