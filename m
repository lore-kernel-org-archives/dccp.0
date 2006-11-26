From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 26 Nov 2006 03:18:15 +0000
Subject: [PATCH 1/4] [DCCP] ackvec: Remove unused dccpav_ack_ptr field from dccp_ackvec
Message-Id: <20061126031815.GB17851@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Commiter note: original patch was splitted.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ackvec.c |    1 -
 net/dccp/ackvec.h |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 1b4b60d..215355d 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -141,7 +141,6 @@ struct dccp_ackvec *dccp_ackvec_alloc(co
 		av->dccpav_buf_head	= DCCP_MAX_ACKVEC_LEN - 1;
 		av->dccpav_buf_ackno	= DCCP_MAX_SEQNO + 1;
 		av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
-		av->dccpav_ack_ptr	= 0;
 		av->dccpav_time.tv_sec	= 0;
 		av->dccpav_time.tv_usec	= 0;
 		av->dccpav_vec_len	= 0;
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index cf8f20c..d6a58db 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -41,7 +41,6 @@ #define DCCP_ACKVEC_LEN_MASK		0x3F /* 00
  * Ack Vectors it has recently sent. For each packet sent carrying an
  * Ack Vector, it remembers four variables:
  *
- * @dccpav_ack_ptr - the value of buf_head at the time of acknowledgement.
  * @dccpav_records - list of dccp_ackvec_record
  * @dccpav_ack_nonce - the one-bit sum of the ECN Nonces for all State 0.
  *
@@ -53,7 +52,6 @@ struct dccp_ackvec {
 	struct list_head dccpav_records;
 	struct timeval	dccpav_time;
 	u8		dccpav_buf_head;
-	u8		dccpav_ack_ptr;
 	u8		dccpav_vec_len;
 	u8		dccpav_buf_nonce;
 	u8		dccpav_ack_nonce;
-- 
1.4.2.1.g3d5c

