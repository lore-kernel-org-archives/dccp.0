From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:09:28 +0000
Subject: [PATCH 3/10]: [DCCP] ackvec: Remove unused variables
Message-Id: <20060914170928.GD20651@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Get rid of unused variables in ackvector state.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c |    5 ++---
 ackvec.h |    4 +---
 2 files changed, 3 insertions(+), 6 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index bc5ff12..4d176d3 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -142,14 +142,13 @@ struct dccp_ackvec *dccp_ackvec_alloc(co
 	struct dccp_ackvec *av = kmem_cache_alloc(dccp_ackvec_slab, priority);
 
 	if (av != NULL) {
-		av->dccpav_buf_head	-			av->dccpav_buf_tail = DCCP_MAX_ACKVEC_LEN - 1;
+		av->dccpav_buf_head	= DCCP_MAX_ACKVEC_LEN - 1;
 		av->dccpav_buf_ackno	= DCCP_MAX_SEQNO + 1;
 		av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
 		av->dccpav_ack_ptr	= 0;
 		av->dccpav_time.tv_sec	= 0;
 		av->dccpav_time.tv_usec	= 0;
-		av->dccpav_sent_len	= av->dccpav_vec_len = 0;
+		av->dccpav_vec_len	= 0;
 		INIT_LIST_HEAD(&av->dccpav_records);
 	}
 
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index 0adf4b5..2424eff 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -54,9 +54,7 @@ struct dccp_ackvec {
 	struct list_head dccpav_records;
 	struct timeval	dccpav_time;
 	u8		dccpav_buf_head;
-	u8		dccpav_buf_tail;
 	u8		dccpav_ack_ptr;
-	u8		dccpav_sent_len;
 	u8		dccpav_vec_len;
 	u8		dccpav_buf_nonce;
 	u8		dccpav_ack_nonce;
@@ -107,7 +105,7 @@ extern int dccp_insert_option_ackvec(str
 
 static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
 {
-	return av->dccpav_sent_len != av->dccpav_vec_len;
+	return av->dccpav_vec_len;
 }
 #else /* CONFIG_IP_DCCP_ACKVEC */
 static inline int dccp_ackvec_init(void)
