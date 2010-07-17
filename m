From: Kulikov Vasiliy <segooon@gmail.com>
Date: Sat, 17 Jul 2010 15:21:00 +0000
Subject: [PATCH 5/5] net: dccp: fix sign bug
Message-Id: <1279380060-15394-1-git-send-email-segooon@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

'gap' is unsigned, so this code is wrong:

    gap = -new_head;
    ...
    if (gap > 0) { ... }

Make 'gap' signed.


The semantic patch that finds this problem (many false-positive results):
(http://coccinelle.lip6.fr/)

// <smpl>
@ r1 @
identifier f;
@@
int f(...) { ... }

@@
identifier r1.f;
type T;
unsigned T x;
@@

*x = f(...)
 ...
*x > 0

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 net/dccp/ackvec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 2abddee..92a6fcb 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -201,7 +201,7 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 						 const unsigned int packets,
 						 const unsigned char state)
 {
-	unsigned int gap;
+	long gap;
 	long new_head;
 
 	if (av->av_vec_len + packets > DCCP_MAX_ACKVEC_LEN)
-- 
1.7.0.4

