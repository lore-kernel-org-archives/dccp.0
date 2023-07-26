From: YueHaibing <yuehaibing@huawei.com>
Date: Wed, 26 Jul 2023 14:32:39 +0000
Subject: [PATCH net-next] dccp: Remove unused declaration dccp_feat_initialise_sysctls()
Message-Id: <20230726143239.9904-1-yuehaibing@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is never used, so can remove it.

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 net/dccp/feat.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/dccp/feat.h b/net/dccp/feat.h
index d76c9be5bfca..57d9c026aa3f 100644
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -105,7 +105,6 @@ extern int	     sysctl_dccp_rx_ccid;
 extern int	     sysctl_dccp_tx_ccid;
 
 int dccp_feat_init(struct sock *sk);
-void dccp_feat_initialise_sysctls(void);
 int dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
 			  u8 const *list, u8 len);
 int dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
-- 
2.34.1
