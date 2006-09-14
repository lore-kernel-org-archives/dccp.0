From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:08:25 +0000
Subject: [PATCH 1/10]: [DCCP] ACKVEC: fix ackvector length calculation
Message-Id: <20060914170823.GB20651@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Fix ackvector length calculation upon receiving an "ack-of-ack".  This patch
avoids the ackvector from growing too large which causes it to not be inserted
into packets.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

------------------------------------------------------------------------------

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
