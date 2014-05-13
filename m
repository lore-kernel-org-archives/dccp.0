From: Wang Weidong <wangweidong1@huawei.com>
Date: Tue, 13 May 2014 02:57:58 +0000
Subject: [PATCH net-next] dccp: make the request_retries minimum is 1
Message-Id: <53718A36.1040907@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In Documentation/networking/dccp.txt points that request_retries
should be greater than 0. So make the extra1 to be &one instead
of &zero.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/dccp/sysctl.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index 607ab71..53731e4 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -20,6 +20,7 @@
 
 /* Boundary values */
 static int		zero     = 0,
+			one      = 1,
 			u8_max   = 0xFF;
 static unsigned long	seqw_min = DCCPF_SEQ_WMIN,
 			seqw_max = 0xFFFFFFFF;		/* maximum on 32 bit */
@@ -58,7 +59,7 @@ static struct ctl_table dccp_default_table[] = {
 		.maxlen		= sizeof(sysctl_dccp_request_retries),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
+		.extra1		= &one,
 		.extra2		= &u8_max,
 	},
 	{
-- 
1.7.12


