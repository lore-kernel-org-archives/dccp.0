From: Yue Haibing <yuehaibing@huawei.com>
Date: Thu, 21 Mar 2019 14:10:58 +0000
Subject: [PATCH] dccp: Fix memleak in __feat_register_sp
Message-Id: <20190321141058.14580-1-yuehaibing@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: YueHaibing <yuehaibing@huawei.com>

If dccp_feat_push_change fails, we forget free the mem
which is alloced by kmemdup in dccp_feat_clone_sp_val.

Reported-by: Hulk Robot <hulkci@huawei.com>
Fixes: e8ef967a54f4 ("dccp: Registration routines for changing feature values")
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 net/dccp/feat.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index f227f00..083e012 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -738,7 +738,12 @@ static int __feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
 	if (dccp_feat_clone_sp_val(&fval, sp_val, sp_len))
 		return -ENOMEM;
 
-	return dccp_feat_push_change(fn, feat, is_local, mandatory, &fval);
+	if (dccp_feat_push_change(fn, feat, is_local, mandatory, &fval)) {
+		kfree(val->sp.vec);
+		return -ENOMEM;
+	}
+
+	return 0;
 }
 
 /**
-- 
2.7.0

