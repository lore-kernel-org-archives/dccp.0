From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 17:51:47 +0000
Subject: [PATCH 01/11] ACKVEC: fix ackvector length calculation
Message-Id: <20060622175147.GA4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Fix ackvector length calculation upon receiving an "ack-of-ack".  This patch
aviods the ackvector from growing too large which causes it to not be inserted
into packets.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 8c211c5..8dab723 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -353,11 +353,13 @@ static void dccp_ackvec_throw_record(str
 {
 	struct dccp_ackvec_record *next;
 
-	av->dccpav_buf_tail = avr->dccpavr_ack_ptr - 1;
-	if (av->dccpav_buf_tail = 0)
-		av->dccpav_buf_tail = DCCP_MAX_ACKVEC_LEN - 1;
-
-	av->dccpav_vec_len -= avr->dccpavr_sent_len;
+	/* sort out vector length */
+	if (av->dccpav_buf_head <= avr->dccpavr_ack_ptr)
+		av->dccpav_vec_len = avr->dccpavr_ack_ptr - av->dccpav_buf_head;
+	else
+		av->dccpav_vec_len = DCCP_MAX_ACKVEC_LEN - 1
+				     - av->dccpav_buf_head
+				     + avr->dccpavr_ack_ptr;
 
 	/* free records */
 	list_for_each_entry_safe_from(avr, next, &av->dccpav_records,
