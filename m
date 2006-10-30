From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Oct 2006 15:55:56 +0000
Subject: [TCPDUMP][WIRESHARK]: validation of variable-length checksums
Message-Id: <200610301555.56283@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_MCiRFhhSz1ND5S5"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_MCiRFhhSz1ND5S5
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Attached are patches for the latest automatic build 
of wireshark and for tcpdump (3.9.5), to support
validation of variable length checksums (RFC 4340, sec. 9).

I have submitted them to the respective lists, but it may
take some time until they surface. 

A kernel patch is on its way, I am just waiting to make
sure I got it correct. 

There is also a ttcp_dccp variant with support for variable
length checksums, I hope to finalise this some time when
finally the socket API is a bit cleaner.

Gerrit

--Boundary-00=_MCiRFhhSz1ND5S5
Content-Type: text/x-diff;
  charset="us-ascii";
  name="tcpdump-partial-csum.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="tcpdump-partial-csum.patch"

diff --git a/dccp.h b/dccp.h
index 1afa8c0..8585060 100644
--- a/dccp.h
+++ b/dccp.h
@@ -36,8 +36,8 @@ struct dccp_hdr {
 	}		dccph_xtrs;
 };
 
-#define DCCPH_CCVAL(dh)	(((dh)->dccph_ccval_cscov) & 0x0F)
-#define DCCPH_CSCOV(dh)	(((dh)->dccph_ccval_cscov >> 4) & 0x0F)
+#define DCCPH_CCVAL(dh)	(((dh)->dccph_ccval_cscov >> 4) & 0xF)
+#define DCCPH_CSCOV(dh)	(((dh)->dccph_ccval_cscov) & 0xF)
 
 #define DCCPH_X(dh)	((dh)->dccph_xtrs.dccph_xtr & 1)
 #define DCCPH_TYPE(dh)	(((dh)->dccph_xtrs.dccph_xtr >> 1) & 0xF)
diff --git a/print-dccp.c b/print-dccp.c
index e6bfca6..d19c500 100644
--- a/print-dccp.c
+++ b/print-dccp.c
@@ -60,9 +60,20 @@ static const char *dccp_feature_nums[] =
 	"check data checksum",
 };
 
+static inline int dccp_csum_coverage(const struct dccp_hdr* dh, u_int len)
+{
+	int cov;
+	
+	if (DCCPH_CSCOV(dh) == 0)
+		return len;
+	cov = (dh->dccph_doff + DCCPH_CSCOV(dh) - 1) * sizeof(u_int32_t);
+	return (cov > len)? len : cov;
+}
+
 static int dccp_cksum(const struct ip *ip,
 	const struct dccp_hdr *dh, u_int len)
 {
+	int cov = dccp_csum_coverage(dh, len);
 	union phu {
 		struct phdr {
 			u_int32_t src;
@@ -86,15 +97,15 @@ static int dccp_cksum(const struct ip *i
 		phu.ph.dst = ip_finddst(ip);
 
 	sp = &phu.pa[0];
-	return in_cksum((u_short *)dh, len, sp[0]+sp[1]+sp[2]+sp[3]+sp[4]+sp[5]);
+	return in_cksum((u_short *)dh, cov, sp[0]+sp[1]+sp[2]+sp[3]+sp[4]+sp[5]);
 }
 
 #ifdef INET6
 static int dccp6_cksum(const struct ip6_hdr *ip6, const struct dccp_hdr *dh, u_int len)
 {
 	size_t i;
-	const u_int16_t *sp;
-	u_int32_t sum;
+	u_int32_t sum = 0;
+	int cov = dccp_csum_coverage(dh, len);
 	union {
 		struct {
 			struct in6_addr ph_src;
@@ -113,23 +124,10 @@ static int dccp6_cksum(const struct ip6_
 	phu.ph.ph_len = htonl(len);
 	phu.ph.ph_nxt = IPPROTO_DCCP;
 
-	sum = 0;
 	for (i = 0; i < sizeof(phu.pa) / sizeof(phu.pa[0]); i++)
 		sum += phu.pa[i];
 
-	sp = (const u_int16_t *)dh;
-
-	for (i = 0; i < (len & ~1); i += 2)
-		sum += *sp++;
-
-	if (len & 1)
-		sum += htons((*(const u_int8_t *)sp) << 8);
-
-	while (sum > 0xffff)
-		sum = (sum & 0xffff) + (sum >> 16);
-	sum = ~sum & 0xffff;
-
-	return (sum);
+	return in_cksum((u_short *)dh, cov, sum);
 }
 #endif
 
@@ -288,7 +286,7 @@ #ifdef INET6
 			dccp_sum = EXTRACT_16BITS(&dh->dccph_checksum);		
 			printf("cksum 0x%04x", dccp_sum);		
 			if (sum != 0) {
-				(void)printf(" (incorrect (-> 0x%04x), ",in_cksum_shouldbe(dccp_sum, sum));
+				(void)printf(" (incorrect -> 0x%04x), ",in_cksum_shouldbe(dccp_sum, sum));
 			} else
 				(void)printf(" (correct), ");
 		}					

--Boundary-00=_MCiRFhhSz1ND5S5
Content-Type: text/x-diff;
  charset="us-ascii";
  name="wireshark-partial-csum.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="wireshark-partial-csum.patch"

--- wireshark-0.99.4-SVN-19738/epan/dissectors/packet-dcp.c.orig	2006-10-30 14:52:53.000000000 +0000
+++ wireshark-0.99.4-SVN-19738/epan/dissectors/packet-dcp.c	2006-10-30 14:53:02.000000000 +0000
@@ -541,6 +541,16 @@
 
 	} /* end while() */
 }
+/* compute DCCP checksum coverage according to RFC 4340, section 9 */
+static inline guint dccp_csum_coverage(const e_dcphdr *dcph, guint len)
+{
+	guint cov;
+	
+	if (dcph->cscov == 0)
+		return len;
+	cov = (dcph->data_offset + dcph->cscov - 1) * sizeof(guint32);
+	return (cov > len)? len : cov;
+}
 
 static void dissect_dcp(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree)
 {
@@ -595,7 +605,8 @@
 	/* DBG("dcph->data_offset: %d\n", dcph->data_offset); */
 	dcph->cscov=tvb_get_guint8(tvb, offset+5)&0x0F;
 	/* DBG("dcph->cscov: %d\n", dcph->cscov); */
-	dcph->ccval=tvb_get_guint8(tvb, offset+5)&0xF0;
+	dcph->ccval=tvb_get_guint8(tvb, offset+5) &0xF0;
+	dcph->ccval >>= 4;
 	/* DBG("dcph->ccval: %d\n", dcph->ccval); */
 	dcph->checksum=tvb_get_ntohs(tvb, offset+6);
 	/* DBG("dcph->checksum: %d\n", dcph->checksum); */
@@ -662,15 +673,11 @@
 		proto_tree_add_uint(dcp_tree, hf_dcp_ccval, tvb, offset + 5, 1, dcph->ccval);
 		proto_tree_add_uint(dcp_tree, hf_dcp_cscov, tvb, offset + 5, 1, dcph->cscov);
 				
-		/* checksum analisys taken from packet-udp */
+		/* checksum analysis taken from packet-udp (difference: mandatory checksums in DCCP) */
 				
 		reported_len = tvb_reported_length(tvb);
 		len = tvb_length(tvb);
-		if (dcph->checksum == 0) {
-			/* No checksum supplied in the packet */
-			proto_tree_add_uint_format_value(dcp_tree, hf_dcp_checksum, tvb,
-							 offset + 6, 2, dcph->checksum, "0x%04x (none)", dcph->checksum);
-		} else if (!pinfo->fragmented && len >= reported_len) {
+		if (!pinfo->fragmented && len >= reported_len) {
 
 			/* The packet isn't part of a fragmented datagram and isn't
 			   truncated, so we can checksum it.
@@ -703,7 +710,7 @@
 					break;
 				}
 				cksum_vec[3].ptr = tvb_get_ptr(tvb, offset, len);
-				cksum_vec[3].len = reported_len;
+				cksum_vec[3].len = dccp_csum_coverage(dcph, reported_len);
 				computed_cksum = in_cksum(&cksum_vec[0], 4);
 				if (computed_cksum == 0) {
 					proto_tree_add_uint_format_value(dcp_tree, hf_dcp_checksum, tvb,

--Boundary-00=_MCiRFhhSz1ND5S5--
