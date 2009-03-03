From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 03 Mar 2009 20:24:55 +0000
Subject: [PATCH] dccp: ensure gap does not become unsigned -1
Message-Id: <49AD9217.8020206@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Is this maybe necessary?
------------------------------>8-------------8<---------------------------------
if packets is 0, becomes -1, but since gap is unsigned, the test 'gap > 0' does
not work.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 01e4d39..7c61bc0 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -207,7 +207,11 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 	if (av->av_vec_len + packets > DCCP_MAX_ACKVEC_LEN)
 		return -ENOBUFS;
 
-	gap	 = packets - 1;
+	if (packets > 0)
+		gap = packets - 1;
+	else
+		gap = 0;
+
 	new_head = av->av_buf_head - packets;
 
 	if (new_head < 0) {
