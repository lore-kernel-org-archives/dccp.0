From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 01 Oct 2014 04:48:03 +0000
Subject: [PATCH 1/1 linux-next] net/dccp/proto.c: add __init to dccp_mib_init
Message-Id: <1412138883-2476-1-git-send-email-fabf@skynet.be>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_mib_init is only called by __init dccp_init in same module.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dccp/proto.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e421edd..6d090c4 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1082,7 +1082,7 @@ void dccp_shutdown(struct sock *sk, int how)
 
 EXPORT_SYMBOL_GPL(dccp_shutdown);
 
-static inline int dccp_mib_init(void)
+static inline int __init dccp_mib_init(void)
 {
 	dccp_statistics = alloc_percpu(struct dccp_mib);
 	if (!dccp_statistics)
-- 
1.9.3

