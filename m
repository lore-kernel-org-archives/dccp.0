From: Colin King <colin.king@canonical.com>
Date: Thu, 13 Jul 2017 11:22:24 +0000
Subject: [PATCH] dccp: make const array error_code static
Message-Id: <20170713112224.31667-1-colin.king@canonical.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Don't populate array error_code on the stack but make it static. Makes
the object code smaller by almost 250 bytes:

Before:
   text	   data	    bss	    dec	    hex	filename
  10366	    983	      0	  11349	   2c55	net/dccp/input.o

After:
   text	   data	    bss	    dec	    hex	filename
  10161	   1039	      0	  11200	   2bc0	net/dccp/input.o

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/dccp/input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 4a05d7876850..fa6be9750bb4 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -126,7 +126,7 @@ static int dccp_rcv_closereq(struct sock *sk, struct sk_buff *skb)
 
 static u16 dccp_reset_code_convert(const u8 code)
 {
-	const u16 error_code[] = {
+	static const u16 error_code[] = {
 	[DCCP_RESET_CODE_CLOSED]	     = 0,	/* normal termination */
 	[DCCP_RESET_CODE_UNSPECIFIED]	     = 0,	/* nothing known */
 	[DCCP_RESET_CODE_ABORTED]	     = ECONNRESET,
-- 
2.11.0

