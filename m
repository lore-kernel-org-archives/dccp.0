From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sun, 19 Nov 2006 02:49:37 +0000
Subject: [PATCH 1/3] DCCP: Make probe more portable
Message-Id: <200611191549.38358.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The probe code for DCCP can be made more portable as per commit
3a872d89baae821a0f6e2c1055d4b47650661137

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
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
