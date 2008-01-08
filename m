From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 08 Jan 2008 14:07:55 +0000
Subject: [PATCH 2/3] [ACKVEC]: Separate skb option parsing from CCID-specific code
Message-Id: <1199801276-16955-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch replaces an almost identical reduplication of code; large parts of
dccp_parse_options() are repeated as ccid2_ackvector() in ccid2.c.

Two problems are involved, apart from the duplication:
 1. no separation of concerns: CCIDs should not need to be concerned with the
    details of parsing header options;
 2. one can not assume that Ack Vectors appear as a contiguous area within an
    skb, it is legal to insert other options and/or padding in between. The
    current code would throw an error and stop reading in such a case. Not good.

Details:
--------
 * received Ack Vectors are parsed by dccp_parse_options() alone, which passes
   the result on to the CCID-specific ccid_hc_tx_parse_options();
 * CCIDs interested in using/decoding Ack Vector information need to add code
   to receive parsed Ack Vectors via this interface;
 * a data structure, `struct dccp_ackvec_parsed' is provided, which arranges all
   Ack Vectors of a single skb into a list of parsed chunks;
 * a doubly-linked list was used since insertion needs to be at the tail end;
 * the associated list handling and list de-allocation routines.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c  |   28 ++++++++++++++++++++++++++++
 net/dccp/ackvec.h  |   19 +++++++++++++++++++
 net/dccp/options.c |   17 ++++++++++-------
 3 files changed, 57 insertions(+), 7 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -112,4 +112,23 @@ static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
 {
 	return av->av_overflow = 0 && av->av_buf_head = av->av_buf_tail;
 }
+
+/**
+ * struct dccp_ackvec_parsed  -  Record offsets of Ack Vectors in skb
+ * @vec:	start of vector (offset into skb)
+ * @len:	length of @vec
+ * @nonce:	whether @vec had an ECN nonce of 0 or 1
+ * @node:	FIFO - arranged in descending order of ack_ackno
+ * This structure is used by CCIDs to access Ack Vectors in a received skb.
+ */
+struct dccp_ackvec_parsed {
+	u8		 *vec,
+			 len,
+			 nonce:1;
+	struct list_head node;
+};
+
+extern int dccp_ackvec_parsed_add(struct list_head *head,
+				  u8 *vec, u8 len, u8 nonce);
+extern void dccp_ackvec_parsed_cleanup(struct list_head *parsed_chunks);
 #endif /* _ACKVEC_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -135,13 +135,6 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			if (rc)
 				goto out_invalid_option;
 			break;
-		case DCCPO_ACK_VECTOR_0:
-		case DCCPO_ACK_VECTOR_1:
-			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
-				break;
-			dccp_pr_debug("%s Ack Vector (len=%u)\n", dccp_role(sk),
-				      len);
-			break;
 		case DCCPO_TIMESTAMP:
 			if (len != 4)
 				goto out_invalid_option;
@@ -229,6 +222,16 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 						     value) != 0)
 				goto out_invalid_option;
 			break;
+		case DCCPO_ACK_VECTOR_0:
+		case DCCPO_ACK_VECTOR_1:
+			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
+				break;
+			/*
+			 * Ack vectors are processed by the TX CCID if it is
+			 * interested. The RX CCID need not parse Ack Vectors,
+			 * since it is only interested in clearing old state.
+			 * Fall through.
+			 */
 		case DCCPO_MIN_TX_CCID_SPECIFIC ... DCCPO_MAX_TX_CCID_SPECIFIC:
 			if (ccid_hc_tx_parse_options(dp->dccps_hc_tx_ccid, sk,
 						     opt, len, value - options,
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -345,6 +345,34 @@ free_records:
 	}
 }
 
+/*
+ *	Routines to keep track of Ack Vectors received in an skb
+ */
+int dccp_ackvec_parsed_add(struct list_head *head, u8 *vec, u8 len, u8 nonce)
+{
+	struct dccp_ackvec_parsed *new = kmalloc(sizeof(*new), GFP_ATOMIC);
+
+	if (new = NULL)
+		return -ENOBUFS;
+	new->vec   = vec;
+	new->len   = len;
+	new->nonce = nonce;
+
+	list_add_tail(&new->node, head);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dccp_ackvec_parsed_add);
+
+void dccp_ackvec_parsed_cleanup(struct list_head *parsed_chunks)
+{
+	struct dccp_ackvec_parsed *cur, *next;
+
+	list_for_each_entry_safe(cur, next, parsed_chunks, node)
+		kfree(cur);
+	INIT_LIST_HEAD(parsed_chunks);
+}
+EXPORT_SYMBOL_GPL(dccp_ackvec_parsed_cleanup);
+
 int __init dccp_ackvec_init(void)
 {
 	dccp_ackvec_slab = kmem_cache_create("dccp_ackvec",
