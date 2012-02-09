From: Samuel Jero <sj323707@ohio.edu>
Date: Thu, 09 Feb 2012 05:10:51 +0000
Subject: [PATCH] Allow Acknowledgment of all valid Response packets
Message-Id: <4F33555B.6070607@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enig47F06BBCEBAD7A00CDEC6278"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--------------enig47F06BBCEBAD7A00CDEC6278
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

All,

In the course of examining the performance of DCCP over long delay links
for a Delay Tolerant Networking related research project, I believe I
have identified a bug in the DCCP code.

The bug is in the handling of state for listening sockets, particularly
the sequence numbers for REQUEST and RESPONSE packets. Currently, the
code only keeps track of one REQUEST sequence number (the Initial
Sequence Received--isr) and one RESPONSE packet (the Initial Sequence
Sent iss). See include/linux/dccp.h line 400 and net/dccp/ipv4.c line 639=
=2E

This becomes a problem when a sender sends multiple REQUESTS (presumably
because of the retransmission timeout). The receiver sends a RESPONSE
for every REQUEST, but only keeps state on the last one.
If the sender eventually ACKs a RESPONSE other than the most recent one
(say because the link has a several second RTT), the receiver will
consider such an ACK to be invalid because it only keeps state for the
most recent RESPONSE (and the such an ACK will acknowledge a sequence
number before the ISS). This results in the connection being reset.

I experienced this bug when I attempted to establish a DCCP connection
with an RTT greater than three seconds. However, I believe this also
violates the RFC 4340, specifically sections 7.1 and 8.5 step 11.
Further, this could cause significant problems if DCCP ever reduces it
first REQUEST timeout.

My fix is to only set the Initial Sequence (Sent/Received) once and to
keep additional state on Greatest Sequence (Sent/Received). That way the
ACKs of old RESPONSEs can be correctly identified and processed.

Samuel Jero
Internetworking Research Group
Ohio University

---

DCCP currently only keeps an Initial Sequence Sent for the RESPONSE
packets it sends and resets this each time it sends a new one. This
causes problems with ACKs for old RESPONSEs. Such ACKs will acknowledge
a packet that is now below the ISS and such connections will therefore
be reset.

This causes problems for connections where retransmitted REQUESTs are
not always due to packet loss (specifically long delay networks), and
violates RFC 4340 7.1

This patch keeps more state (a GSR and GSS) on REQUEST/RESPONSE packets
so that we can correctly identify and accept ACKs for old RESPONSEs.

---

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index c188f5e..9beb840 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -400,6 +400,8 @@ struct dccp_request_sock {
 	struct inet_request_sock dreq_inet_rsk;
 	__u64			 dreq_iss;
 	__u64			 dreq_isr;
+	__u64			 dreq_gss;
+	__u64			 dreq_gsr;
 	__be32			 dreq_service;
 	struct list_head	 dreq_featneg;
 	__u32			 dreq_timestamp_echo;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 9440e98..084b504 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -296,7 +296,8 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info=
)
 		 */
 		WARN_ON(req->sk);

-		if (seq !=3D dccp_rsk(req)->dreq_iss) {
+		if (seq < dccp_rsk(req)->dreq_iss ||
+						seq > dccp_rsk(req)->dreq_gss) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
@@ -639,7 +639,9 @@ int dccp_v4_conn_request(struct sock *sk, struct
sk_buff *skb)
 	 * dccp_create_openreq_child.
 	 */
 	dreq->dreq_isr	   =3D dcb->dccpd_seq;
+	dreq->dreq_gsr	   =3D dreq->dreq_isr;
 	dreq->dreq_iss	   =3D dccp_v4_init_sequence(skb);
+	dreq->dreq_gss     =3D dreq->dreq_iss;
 	dreq->dreq_service =3D service;

 	if (dccp_v4_send_response(sk, req, NULL))
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4b9d691..483fc6f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -192,7 +192,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct
inet6_skb_parm *opt,
 		 */
 		WARN_ON(req->sk !=3D NULL);

-		if (seq !=3D dccp_rsk(req)->dreq_iss) {
+		if (seq < dccp_rsk(req)->dreq_iss ||
+						seq > dccp_rsk(req)->dreq_gss) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
@@ -443,7 +443,9 @@ static int dccp_v6_conn_request(struct sock *sk,
struct sk_buff *skb)
 	 *   dccp_create_openreq_child.
 	 */
 	dreq->dreq_isr	   =3D dcb->dccpd_seq;
+	dreq->dreq_gsr     =3D dreq->dreq_isr;
 	dreq->dreq_iss	   =3D dccp_v6_init_sequence(skb);
+	dreq->dreq_gss     =3D dreq->dreq_iss;
 	dreq->dreq_service =3D service;

 	if (dccp_v6_send_response(sk, req, NULL))
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 5a7f90b..ab831e8 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -127,9 +127,11 @@ struct sock *dccp_create_openreq_child(struct sock *=
sk,
 		 *    activation below, as these windows all depend on the local
 		 *    and remote Sequence Window feature values (7.5.2).
 		 */
-		newdp->dccps_gss =3D newdp->dccps_iss =3D dreq->dreq_iss;
+		newdp->dccps_iss =3D dreq->dreq_iss;
+		newdp->dccps_gss =3D dreq->dreq_gss;
 		newdp->dccps_gar =3D newdp->dccps_iss;
-		newdp->dccps_gsr =3D newdp->dccps_isr =3D dreq->dreq_isr;
+		newdp->dccps_isr =3D dreq->dreq_isr;
+		newdp->dccps_gsr =3D dreq->dreq_gsr;

 		/*
 		 * Activate features: initialise CCIDs, sequence windows etc.
@@ -164,9 +166,9 @@ struct sock *dccp_check_req(struct sock *sk, struct
sk_buff *skb,
 	/* Check for retransmitted REQUEST */
 	if (dccp_hdr(skb)->dccph_type =3D=3D DCCP_PKT_REQUEST) {

-		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_isr)) {
+		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_gsr)) {
 			dccp_pr_debug("Retransmitted REQUEST\n");
-			dreq->dreq_isr =3D DCCP_SKB_CB(skb)->dccpd_seq;
+			dreq->dreq_gsr =3D DCCP_SKB_CB(skb)->dccpd_seq;
 			/*
 			 * Send another RESPONSE packet
 			 * To protect against Request floods, increment retrans
@@ -186,12 +188,14 @@ struct sock *dccp_check_req(struct sock *sk,
struct sk_buff *skb,
 		goto drop;

 	/* Invalid ACK */
-	if (DCCP_SKB_CB(skb)->dccpd_ack_seq !=3D dreq->dreq_iss) {
+	if (DCCP_SKB_CB(skb)->dccpd_ack_seq < dreq->dreq_iss ||
+			DCCP_SKB_CB(skb)->dccpd_ack_seq > dreq->dreq_gss) {
 		dccp_pr_debug("Invalid ACK number: ack_seq=3D%llu, "
-			      "dreq_iss=3D%llu\n",
+			      "dreq_iss=3D%llu,dreq_gss=3D%llu\n",
 			      (unsigned long long)
 			      DCCP_SKB_CB(skb)->dccpd_ack_seq,
-			      (unsigned long long) dreq->dreq_iss);
+			      (unsigned long long) dreq->dreq_iss,
+			      (unsigned long long) dreq->dreq_gss);
 		goto drop;
 	}

diff --git a/net/dccp/output.c b/net/dccp/output.c
index ccb9844..c51c71e 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -423,10 +423,10 @@ struct sk_buff *dccp_make_response(struct sock
*sk, struct dst_entry *dst,
 	skb_dst_set(skb, dst_clone(dst));

 	dreq =3D dccp_rsk(req);
-	if (inet_rsk(req)->acked)	/* increase ISS upon retransmission */
-		dccp_inc_seqno(&dreq->dreq_iss);
+	if (inet_rsk(req)->acked)	/* increase GSS upon retransmission */
+		dccp_inc_seqno(&dreq->dreq_gss);
 	DCCP_SKB_CB(skb)->dccpd_type =3D DCCP_PKT_RESPONSE;
-	DCCP_SKB_CB(skb)->dccpd_seq  =3D dreq->dreq_iss;
+	DCCP_SKB_CB(skb)->dccpd_seq  =3D dreq->dreq_gss;

 	/* Resolve feature dependencies resulting from choice of CCID */
 	if (dccp_feat_server_ccid_dependencies(dreq))
@@ -444,8 +444,8 @@ struct sk_buff *dccp_make_response(struct sock *sk,
struct dst_entry *dst,
 			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;
 	dh->dccph_type	=3D DCCP_PKT_RESPONSE;
 	dh->dccph_x	=3D 1;
-	dccp_hdr_set_seq(dh, dreq->dreq_iss);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_isr);
+	dccp_hdr_set_seq(dh, dreq->dreq_gss);
+	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_gsr);
 	dccp_hdr_response(skb)->dccph_resp_service =3D dreq->dreq_service;

 	dccp_csum_outgoing(skb);


--------------enig47F06BBCEBAD7A00CDEC6278
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk8zVV0ACgkQEwoGUlJjrt8urQCeJPRvISsWbV5tMCRdIhA1tlzv
PvQAoKGnknIIHbJogWnbSOXT4xtCN3D5
=W1gY
-----END PGP SIGNATURE-----

--------------enig47F06BBCEBAD7A00CDEC6278--
