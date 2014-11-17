From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 17 Nov 2014 20:58:37 +0000
Subject: [PATCH 1/1 net-next] dccp: replace min/casting by min_t
Message-Id: <1416257917-7041-1-git-send-email-fabf@skynet.be>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dccp/ackvec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index ba07824..bd9e718 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -218,7 +218,7 @@ static void dccp_ackvec_add_new(struct dccp_ackvec *av, u32 num_packets,
 		 * different underlying data structure.
 		 */
 		for (num_packets = num_cells = 1; lost_packets; ++num_cells) {
-			u8 len = min(lost_packets, (u32)DCCPAV_MAX_RUNLEN);
+			u8 len = min_t(u32, lost_packets, DCCPAV_MAX_RUNLEN);
 
 			av->av_buf_head = __ackvec_idx_sub(av->av_buf_head, 1);
 			av->av_buf[av->av_buf_head] = DCCPAV_NOT_RECEIVED | len;
-- 
1.9.3

