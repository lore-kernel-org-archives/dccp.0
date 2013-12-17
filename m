From: Wang Weidong <wangweidong1@huawei.com>
Date: Tue, 17 Dec 2013 12:30:17 +0000
Subject: [PATCH net-next] dccp: add check request_moduls in setup_jprobe
Message-Id: <52B043D9.9090808@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

when register_jprobe failed, we will try request_module. But some
time request_module will failed such as the dccp is not exist. so
check the request_module for avoiding do register_jprobe again.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/dccp/probe.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 4c6bdf9..53158d2 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -157,9 +157,12 @@ static __init int setup_jprobe(void)
 	int ret = register_jprobe(&dccp_send_probe);
 
 	if (ret) {
-		request_module("dccp");
+		if (request_module("dccp"))
+			goto out;
 		ret = register_jprobe(&dccp_send_probe);
 	}
+
+out:
 	return ret;
 }
 
-- 
1.7.12


