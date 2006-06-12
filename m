From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Mon, 12 Jun 2006 17:56:03 +0000
Subject: [PATCH 1/1] DCCP fix calculation of ackvec length
Message-Id: <20060612175603.GA2279@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The length of the ack vector was incorrectly calculated upon the reception of an
"ack-of-an-ack".  This would cause the length to become "negative" [i.e. the
integer would wrap] causing an incorrect ack vector which was too long.
Consequently, the ackvector could not be inserted into packets as an option [it
semply was too long] and all packets transmitted would get dropped.  This
includes dropping pure ACKs.  Eventually, even the sender on the other side
would stop because ACKs are not being sent by the receiver.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 2349078..6e7d91c 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -354,11 +373,14 @@ static void dccp_ackvec_throw_record(str
 {
 	struct dccp_ackvec_record *next;
 
-	av->dccpav_buf_tail = avr->dccpavr_ack_ptr - 1;
-	if (av->dccpav_buf_tail = 0)
-		av->dccpav_buf_tail = DCCP_MAX_ACKVEC_LEN - 1;
-
-	av->dccpav_vec_len -= avr->dccpavr_sent_len;
+	/* sort out vector length */
+	if (av->dccpav_buf_head <= avr->dccpavr_ack_ptr) {
+		av->dccpav_vec_len = avr->dccpavr_ack_ptr - av->dccpav_buf_head;
+	}
+	else {
+		av->dccpav_vec_len = DCCP_MAX_ACKVEC_LEN - 1 - av->dccpav_buf_head
+				     + avr->dccpavr_ack_ptr;
+	}
 
 	/* free records */
 	list_for_each_entry_safe_from(avr, next, &av->dccpav_records,
