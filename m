From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 20 Nov 2006 20:57:10 +0000
Subject: [PATCH 7/9] [DCCP]: Make dccp_probe more portable
Message-Id: <20061120205710.GH5246@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This makes the code of the dccp_probe module more portable.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/probe.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 146496f..ac8bfb3 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -106,8 +106,10 @@ static int jdccp_sendmsg(struct kiocb *i
 }
 
 static struct jprobe dccp_send_probe = {
-	.kp	= { .addr = (kprobe_opcode_t *)&dccp_sendmsg, },
-	.entry	= (kprobe_opcode_t *)&jdccp_sendmsg,
+	.kp	= {
+		.symbol_name = "dccp_sendmsg",
+	},
+	.entry	= JPROBE_ENTRY(jdccp_sendmsg),
 };
 
 static int dccpprobe_open(struct inode *inode, struct file *file)
-- 
1.4.2.1.g3d5c

