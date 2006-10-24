From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 13:59:43 +0000
Subject: [PATCH 6/17] [DCCP]: Combine allocating & zeroing header space on skb
Message-Id: <200610241459.43866@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Combine allocating & zeroing header space on skb

This is a code simplification: 
it combines three often recurring operations into one inline function,

	* allocate `len' bytes header space in skb
	* fill these `len' bytes with zeroes
	* cast the start of this header space as dccp_hdr



Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 include/linux/dccp.h |    7 +++++++
 net/dccp/ipv4.c      |    9 ++-------
 net/dccp/ipv6.c      |    8 ++------
 net/dccp/output.c    |   14 +++-----------
 4 files changed, 14 insertions(+), 24 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index d6f4ec4..bec3263 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -256,6 +256,13 @@ static inline struct dccp_hdr *dccp_hdr(
 	return (struct dccp_hdr *)skb->h.raw;
 }
 
+static inline struct dccp_hdr *dccp_zeroed_hdr(struct sk_buff *skb, int headlen)
+{
+	skb->h.raw = skb_push(skb, headlen);
+	memset(skb->h.raw, 0, headlen);
+	return dccp_hdr(skb);
+}
+
 static inline struct dccp_hdr_ext *dccp_hdrx(const struct sk_buff *skb)
 {
 	return (struct dccp_hdr_ext *)(skb->h.raw + sizeof(struct dccp_hdr));
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 7102e3a..728255b 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -88,11 +88,9 @@ static int dccp_transmit_skb(struct sock
 			return -EPROTO;
 		}
 		
-		skb->h.raw = skb_push(skb, dccp_header_size);
-		dh = dccp_hdr(skb);
 
 		/* Build DCCP header and checksum it. */
-		memset(dh, 0, dccp_header_size);
+		dh = dccp_zeroed_hdr(skb, dccp_header_size);
 		dh->dccph_type	= dcb->dccpd_type;
 		dh->dccph_sport	= inet->sport;
 		dh->dccph_dport	= inet->dport;
@@ -340,10 +338,7 @@ struct sk_buff *dccp_make_response(struc
 		return NULL;
 	}
 
-	skb->h.raw = skb_push(skb, dccp_header_size);
-
-	dh = dccp_hdr(skb);
-	memset(dh, 0, dccp_header_size);
+	dh = dccp_zeroed_hdr(skb, dccp_header_size);
 
 	dh->dccph_sport	= inet_sk(sk)->sport;
 	dh->dccph_dport	= inet_rsk(req)->rmt_port;
@@ -392,10 +387,7 @@ static struct sk_buff *dccp_make_reset(s
 		return NULL;
 	}
 
-	skb->h.raw = skb_push(skb, dccp_header_size);
-
-	dh = dccp_hdr(skb);
-	memset(dh, 0, dccp_header_size);
+	dh = dccp_zeroed_hdr(skb, dccp_header_size);
 
 	dh->dccph_sport	= inet_sk(sk)->sport;
 	dh->dccph_dport	= inet_sk(sk)->dport;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a31ddd9..e18e66e 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -212,12 +212,9 @@ static void dccp_v4_reqsk_send_ack(struc
 
 	/* Reserve space for headers. */
 	skb_reserve(skb, dccp_v4_ctl_socket->sk->sk_prot->max_header);
-
 	skb->dst = dst_clone(rxskb->dst);
 
-	skb->h.raw = skb_push(skb, dccp_hdr_ack_len);
-	dh = dccp_hdr(skb);
-	memset(dh, 0, dccp_hdr_ack_len);
+	dh = dccp_zeroed_hdr(skb, dccp_hdr_ack_len);
 
 	/* Build DCCP header and checksum it. */
 	dh->dccph_type	   = DCCP_PKT_ACK;
@@ -718,9 +715,7 @@ static void dccp_v4_ctl_send_reset(struc
 	skb_reserve(skb, dccp_v4_ctl_socket->sk->sk_prot->max_header);
 	skb->dst = dst_clone(dst);
 
-	skb->h.raw = skb_push(skb, dccp_hdr_reset_len);
-	dh = dccp_hdr(skb);
-	memset(dh, 0, dccp_hdr_reset_len);
+	dh = dccp_zeroed_hdr(skb, dccp_hdr_reset_len);
 
 	/* Build DCCP header and checksum it. */
 	dh->dccph_type	   = DCCP_PKT_RESET;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 34467bb..3d908eb 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -537,9 +537,7 @@ static void dccp_v6_ctl_send_reset(struc
 
 	skb_reserve(skb, dccp_v6_ctl_socket->sk->sk_prot->max_header);
 
-	skb->h.raw = skb_push(skb, dccp_hdr_reset_len);
-	dh = dccp_hdr(skb);
-	memset(dh, 0, dccp_hdr_reset_len);
+	dh = dccp_zeroed_hdr(skb, dccp_hdr_reset_len);
 
 	/* Swap the send and the receive. */
 	dh->dccph_type	= DCCP_PKT_RESET;
@@ -601,9 +599,7 @@ static void dccp_v6_reqsk_send_ack(struc
 
 	skb_reserve(skb, dccp_v6_ctl_socket->sk->sk_prot->max_header);
 
-	skb->h.raw = skb_push(skb, dccp_hdr_ack_len);
-	dh = dccp_hdr(skb);
-	memset(dh, 0, dccp_hdr_ack_len);
+	dh = dccp_zeroed_hdr(skb, dccp_hdr_ack_len);
 
 	/* Build DCCP header and checksum it. */
 	dh->dccph_type	= DCCP_PKT_ACK;

