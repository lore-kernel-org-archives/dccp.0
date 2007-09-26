From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 18:39:58 +0000
Subject: [PATCH 4/8] [DCCP]: Add Support for Data 1 .. 3 fields of Reset
Message-Id: <20070926183958.GF10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds fields to support the informational Data 1..3 fields of the
DCCP-Reset packets (RFC 4340, 5.6), and makes minor cosmetic changes
to documentation.
Code which fills in these fields follows in subsequent patches, it is
primarily used for reporting option-processing and feature-negotiation
errors.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 include/linux/dccp.h |   14 ++++++--------
 net/dccp/dccp.h      |   14 +++++++++++++-
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index a044119..20e0717 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -56,10 +56,9 @@ struct dccp_hdr_ext {
 };
 
 /**
- * struct dccp_hdr_request - Conection initiation request header
+ * struct dccp_hdr_request - Connection initiation request header
  *
  * @dccph_req_service - Service to which the client app wants to connect
- * @dccph_req_options - list of options (must be a multiple of 32 bits
  */
 struct dccp_hdr_request {
 	__be32	dccph_req_service;
@@ -76,12 +75,10 @@ struct dccp_hdr_ack_bits {
 	__be32	dccph_ack_nr_low;
 };
 /**
- * struct dccp_hdr_response - Conection initiation response header
+ * struct dccp_hdr_response - Connection initiation response header
  *
- * @dccph_resp_ack_nr_high - 48 bit ack number high order bits, contains GSR
- * @dccph_resp_ack_nr_low - 48 bit ack number low order bits, contains GSR
+ * @dccph_resp_ack - 48 bit Acknowledgment Number Subheader (5.3)
  * @dccph_resp_service - Echoes the Service Code on a received DCCP-Request
- * @dccph_resp_options - list of options (must be a multiple of 32 bits
  */
 struct dccp_hdr_response {
 	struct dccp_hdr_ack_bits	dccph_resp_ack;
@@ -91,8 +88,9 @@ struct dccp_hdr_response {
 /**
  * struct dccp_hdr_reset - Unconditionally shut down a connection
  *
- * @dccph_reset_service - Echoes the Service Code on a received DCCP-Request
- * @dccph_reset_options - list of options (must be a multiple of 32 bits
+ * @dccph_reset_ack - 48 bit Acknowledgment Number Subheader (5.6)
+ * @dccph_reset_code - one of %dccp_reset_codes
+ * @dccph_reset_data - the Data 1 ... Data 3 fields from 5.6
  */
 struct dccp_hdr_reset {
 	struct dccp_hdr_ack_bits	dccph_reset_ack;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f62eeb3..e282201 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -308,10 +308,22 @@ static inline int dccp_bad_service_code(const struct sock *sk,
 	return !dccp_list_has_service(dp->dccps_service_list, service);
 }
 
+/**
+ * dccp_skb_cb  -  DCCP per-packet control information
+ * @dccpd_type: one of %dccp_pkt_type (or unknown)
+ * @dccpd_ccval: CCVal field (5.1), see e.g. RFC 4342, 8.1
+ * @dccpd_reset_code: one of %dccp_reset_codes
+ * @dccpd_reset_data: Data1..3 fields (depend on @dccpd_reset_code)
+ * @dccpd_opt_len: total length of all options (5.8) in the packet
+ * @dccpd_seq: sequence number
+ * @dccpd_ack_seq: acknowledgment number subheader field value
+ * This is used for transmission as well as for reception.
+ */
 struct dccp_skb_cb {
 	__u8  dccpd_type:4;
 	__u8  dccpd_ccval:4;
-	__u8  dccpd_reset_code;
+	__u8  dccpd_reset_code,
+	      dccpd_reset_data[3];
 	__u16 dccpd_opt_len;
 	__u64 dccpd_seq;
 	__u64 dccpd_ack_seq;
-- 
1.5.2.2

