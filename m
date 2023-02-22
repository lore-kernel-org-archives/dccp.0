From: Hangyu Hua <hbh25y@gmail.com>
Date: Wed, 22 Feb 2023 06:24:57 +0000
Subject: [PATCH v2] net: dccp: delete redundant ackvec record in dccp_insert_options()
Message-Id: <20230222062457.630849-1-hbh25y@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A useless record can be insert into av_records when dccp_insert_options()
fails after dccp_insert_option_ackvec(). Repeated triggering may cause
av_records to have a lot of useless record with the same avr_ack_seqno.

Fixes: 8b7b6c75c638 ("dccp: Integrate feature-negotiation insertion code")
Signed-off-by: Hangyu Hua <hbh25y@gmail.com>
---

	v2: add a new function to delete the redundant ackvec record

 net/dccp/ackvec.c  | 17 +++++++++++++++++
 net/dccp/ackvec.h  |  1 +
 net/dccp/options.c |  8 ++++++--
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index c4bbac99740d..59b7209c6194 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -273,6 +273,23 @@ void dccp_ackvec_input(struct dccp_ackvec *av, struct sk_buff *skb)
 	}
 }
 
+/**
+ * dccp_ackvec_delete  -  delete an Ack Vector record
+ * @av: Ack Vector records to delete
+ * @ackno: Ack Vector which needs to be deleted
+ */
+void dccp_ackvec_delete(struct dccp_ackvec *av, const u64 ackno)
+{
+	struct dccp_ackvec_record *avr;
+
+	avr = dccp_ackvec_lookup(&av->av_records, ackno);
+	if (!avr)
+		return;
+
+	list_del(&avr->avr_node);
+	kmem_cache_free(dccp_ackvec_record_slab, avr);
+}
+
 /**
  * dccp_ackvec_clear_state  -  Perform house-keeping / garbage-collection
  * @av: Ack Vector record to clean
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index d2c4220fb377..73636971448e 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -106,6 +106,7 @@ struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority);
 void dccp_ackvec_free(struct dccp_ackvec *av);
 
 void dccp_ackvec_input(struct dccp_ackvec *av, struct sk_buff *skb);
+void dccp_ackvec_delete(struct dccp_ackvec *av, const u64 ackno);
 int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
 void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
 u16 dccp_ackvec_buflen(const struct dccp_ackvec *av);
diff --git a/net/dccp/options.c b/net/dccp/options.c
index d24cad05001e..88c966111662 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -549,6 +549,7 @@ static void dccp_insert_option_padding(struct sk_buff *skb)
 int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
@@ -577,16 +578,19 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 
 	if (dp->dccps_hc_rx_insert_options) {
 		if (ccid_hc_rx_insert_options(dp->dccps_hc_rx_ccid, sk, skb))
-			return -1;
+			goto delete_ackvec;
 		dp->dccps_hc_rx_insert_options = 0;
 	}
 
 	if (dp->dccps_timestamp_echo != 0 &&
 	    dccp_insert_option_timestamp_echo(dp, NULL, skb))
-		return -1;
+		goto delete_ackvec;
 
 	dccp_insert_option_padding(skb);
 	return 0;
+delete_ackvec:
+	dccp_ackvec_delete(av, DCCP_SKB_CB(skb)->dccpd_seq);
+	return -1;
 }
 
 int dccp_insert_options_rsk(struct dccp_request_sock *dreq, struct sk_buff *skb)
-- 
2.34.1
