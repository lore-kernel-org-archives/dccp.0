From: Samuel Jero <sj323707@ohio.edu>
Date: Tue, 21 Feb 2012 04:57:36 +0000
Subject: Re: [PATCH] Allow Acknowledgment of all valid Response packets
Message-Id: <4F432440.50207@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enigC7B5626D5BBCAB6B37210676"
List-Id: <dccp.vger.kernel.org>
References: <4F33555B.6070607@ohio.edu>
In-Reply-To: <4F33555B.6070607@ohio.edu>
To: dccp@vger.kernel.org

--------------enigC7B5626D5BBCAB6B37210676
Content-Type: multipart/mixed;
 boundary="------------080803000801000909030700"

This is a multi-part message in MIME format.
--------------080803000801000909030700
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

> Thank you for the patch. What I am asking myself is whether the problem=
 is
>  * specific to links with a long RTT or
>  * can be used in general for all links?

I would argue that this patch is important for all links. Without it, the=
 DCCP
REQUEST/RESPONSE handling is broken. If multiple REQUESTS are sent and no=
thing
gets lost, the connection will be reset.

It is true that this should only happen when DCCP is operating over a lin=
k with
a very long RTT because of the default timeout value (which is much large=
r that
RFC 4340 recommends). However, it's the principle that I'm more concerned=
 with.
DCCP aught to be able to handle this situation even if it never sees it i=
n
normal operation.

Further, I would note that this could easily be turned into a DOS attack.=
 All
that needs to be done is to duplicate the REQUEST packet, increment it's
sequence number, and make sure it gets to the receiver before the first A=
ck gets
there (within 1 RTT).

> I believe the patch is useful, but am not sure using it for the general=
 case,
> need to work through the implications. Also the patch did not apply due=
 to=20
> line-wrap, I tried to fix this manually but there were several places.

Oops, I've attached the patch to this email, and tried to tell my mail cl=
ient
not to wrap the lines below. Hopefully that fixes the issue.

> Also, there are other things in DCCP that currently will not work well =
over long-delay links:
>  * DCCP_TIMEOUT_INIT of 3 seconds (you mentioned this already in your e=
mail)
>  * DCCP_SANE_RTT_MAX =3D 3 seconds  (only used by ccid3/4)
>=20
> I wonder thus if it makes sense to introduce a compilation flag "DCCP_L=
ONG_DELAY_LINKS"
> which changes these parameters and which would conditionally enable you=
r patch?

At the moment, I've simply changed DCCP_SANE_RTT_MAX when I compile for m=
y
testing. It might be a good idea to introduce such a compilation flag, to=
 adjust
that variable (and possibly DCCP_TIMEOUT_INIT).

Samuel Jero
Internetworking Research Group
Ohio University

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
=20
-		if (seq !=3D dccp_rsk(req)->dreq_iss) {
+		if (seq < dccp_rsk(req)->dreq_iss ||
+						seq > dccp_rsk(req)->dreq_gss) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
@@ -639,7 +639,9 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_b=
uff *skb)
 	 * dccp_create_openreq_child.
 	 */
 	dreq->dreq_isr	   =3D dcb->dccpd_seq;
+	dreq->dreq_gsr	   =3D dreq->dreq_isr;
 	dreq->dreq_iss	   =3D dccp_v4_init_sequence(skb);
+	dreq->dreq_gss     =3D dreq->dreq_iss;
 	dreq->dreq_service =3D service;
=20
 	if (dccp_v4_send_response(sk, req, NULL))
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4b9d691..483fc6f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -192,7 +192,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct i=
net6_skb_parm *opt,
 		 */
 		WARN_ON(req->sk !=3D NULL);
=20
-		if (seq !=3D dccp_rsk(req)->dreq_iss) {
+		if (seq < dccp_rsk(req)->dreq_iss ||
+						seq > dccp_rsk(req)->dreq_gss) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
@@ -443,7 +443,9 @@ static int dccp_v6_conn_request(struct sock *sk, stru=
ct sk_buff *skb)
 	 *   dccp_create_openreq_child.
 	 */
 	dreq->dreq_isr	   =3D dcb->dccpd_seq;
+	dreq->dreq_gsr     =3D dreq->dreq_isr;
 	dreq->dreq_iss	   =3D dccp_v6_init_sequence(skb);
+	dreq->dreq_gss     =3D dreq->dreq_iss;
 	dreq->dreq_service =3D service;
=20
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
=20
 		/*
 		 * Activate features: initialise CCIDs, sequence windows etc.
@@ -164,9 +166,9 @@ struct sock *dccp_check_req(struct sock *sk, struct s=
k_buff *skb,
 	/* Check for retransmitted REQUEST */
 	if (dccp_hdr(skb)->dccph_type =3D=3D DCCP_PKT_REQUEST) {
=20
-		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_isr)) {
+		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_gsr)) {
 			dccp_pr_debug("Retransmitted REQUEST\n");
-			dreq->dreq_isr =3D DCCP_SKB_CB(skb)->dccpd_seq;
+			dreq->dreq_gsr =3D DCCP_SKB_CB(skb)->dccpd_seq;
 			/*
 			 * Send another RESPONSE packet
 			 * To protect against Request floods, increment retrans
@@ -186,12 +188,14 @@ struct sock *dccp_check_req(struct sock *sk, struct=
 sk_buff *skb,
 		goto drop;
=20
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
=20
diff --git a/net/dccp/output.c b/net/dccp/output.c
index ccb9844..c51c71e 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -423,10 +423,10 @@ struct sk_buff *dccp_make_response(struct sock *sk,=
 struct dst_entry *dst,
 	skb_dst_set(skb, dst_clone(dst));
=20
 	dreq =3D dccp_rsk(req);
-	if (inet_rsk(req)->acked)	/* increase ISS upon retransmission */
-		dccp_inc_seqno(&dreq->dreq_iss);
+	if (inet_rsk(req)->acked)	/* increase GSS upon retransmission */
+		dccp_inc_seqno(&dreq->dreq_gss);
 	DCCP_SKB_CB(skb)->dccpd_type =3D DCCP_PKT_RESPONSE;
-	DCCP_SKB_CB(skb)->dccpd_seq  =3D dreq->dreq_iss;
+	DCCP_SKB_CB(skb)->dccpd_seq  =3D dreq->dreq_gss;
=20
 	/* Resolve feature dependencies resulting from choice of CCID */
 	if (dccp_feat_server_ccid_dependencies(dreq))
@@ -444,8 +444,8 @@ struct sk_buff *dccp_make_response(struct sock *sk, s=
truct dst_entry *dst,
 			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;
 	dh->dccph_type	=3D DCCP_PKT_RESPONSE;
 	dh->dccph_x	=3D 1;
-	dccp_hdr_set_seq(dh, dreq->dreq_iss);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_isr);
+	dccp_hdr_set_seq(dh, dreq->dreq_gss);
+	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_gsr);
 	dccp_hdr_response(skb)->dccph_resp_service =3D dreq->dreq_service;
=20
 	dccp_csum_outgoing(skb);

--------------080803000801000909030700
Content-Type: text/x-patch;
 name="Track_Request_Response_Seq_Nums.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="Track_Request_Response_Seq_Nums.patch"

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
=20
-		if (seq !=3D dccp_rsk(req)->dreq_iss) {
+		if (seq < dccp_rsk(req)->dreq_iss ||
+						seq > dccp_rsk(req)->dreq_gss) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
@@ -639,7 +639,9 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_b=
uff *skb)
 	 * dccp_create_openreq_child.
 	 */
 	dreq->dreq_isr	   =3D dcb->dccpd_seq;
+	dreq->dreq_gsr	   =3D dreq->dreq_isr;
 	dreq->dreq_iss	   =3D dccp_v4_init_sequence(skb);
+	dreq->dreq_gss     =3D dreq->dreq_iss;
 	dreq->dreq_service =3D service;
=20
 	if (dccp_v4_send_response(sk, req, NULL))
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4b9d691..483fc6f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -192,7 +192,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct i=
net6_skb_parm *opt,
 		 */
 		WARN_ON(req->sk !=3D NULL);
=20
-		if (seq !=3D dccp_rsk(req)->dreq_iss) {
+		if (seq < dccp_rsk(req)->dreq_iss ||
+						seq > dccp_rsk(req)->dreq_gss) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
@@ -443,7 +443,9 @@ static int dccp_v6_conn_request(struct sock *sk, stru=
ct sk_buff *skb)
 	 *   dccp_create_openreq_child.
 	 */
 	dreq->dreq_isr	   =3D dcb->dccpd_seq;
+	dreq->dreq_gsr     =3D dreq->dreq_isr;
 	dreq->dreq_iss	   =3D dccp_v6_init_sequence(skb);
+	dreq->dreq_gss     =3D dreq->dreq_iss;
 	dreq->dreq_service =3D service;
=20
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
=20
 		/*
 		 * Activate features: initialise CCIDs, sequence windows etc.
@@ -164,9 +166,9 @@ struct sock *dccp_check_req(struct sock *sk, struct s=
k_buff *skb,
 	/* Check for retransmitted REQUEST */
 	if (dccp_hdr(skb)->dccph_type =3D=3D DCCP_PKT_REQUEST) {
=20
-		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_isr)) {
+		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_gsr)) {
 			dccp_pr_debug("Retransmitted REQUEST\n");
-			dreq->dreq_isr =3D DCCP_SKB_CB(skb)->dccpd_seq;
+			dreq->dreq_gsr =3D DCCP_SKB_CB(skb)->dccpd_seq;
 			/*
 			 * Send another RESPONSE packet
 			 * To protect against Request floods, increment retrans
@@ -186,12 +188,14 @@ struct sock *dccp_check_req(struct sock *sk, struct=
 sk_buff *skb,
 		goto drop;
=20
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
=20
diff --git a/net/dccp/output.c b/net/dccp/output.c
index ccb9844..c51c71e 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -423,10 +423,10 @@ struct sk_buff *dccp_make_response(struct sock *sk,=
 struct dst_entry *dst,
 	skb_dst_set(skb, dst_clone(dst));
=20
 	dreq =3D dccp_rsk(req);
-	if (inet_rsk(req)->acked)	/* increase ISS upon retransmission */
-		dccp_inc_seqno(&dreq->dreq_iss);
+	if (inet_rsk(req)->acked)	/* increase GSS upon retransmission */
+		dccp_inc_seqno(&dreq->dreq_gss);
 	DCCP_SKB_CB(skb)->dccpd_type =3D DCCP_PKT_RESPONSE;
-	DCCP_SKB_CB(skb)->dccpd_seq  =3D dreq->dreq_iss;
+	DCCP_SKB_CB(skb)->dccpd_seq  =3D dreq->dreq_gss;
=20
 	/* Resolve feature dependencies resulting from choice of CCID */
 	if (dccp_feat_server_ccid_dependencies(dreq))
@@ -444,8 +444,8 @@ struct sk_buff *dccp_make_response(struct sock *sk, s=
truct dst_entry *dst,
 			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;
 	dh->dccph_type	=3D DCCP_PKT_RESPONSE;
 	dh->dccph_x	=3D 1;
-	dccp_hdr_set_seq(dh, dreq->dreq_iss);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_isr);
+	dccp_hdr_set_seq(dh, dreq->dreq_gss);
+	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_gsr);
 	dccp_hdr_response(skb)->dccph_resp_service =3D dreq->dreq_service;
=20
 	dccp_csum_outgoing(skb);


--------------080803000801000909030700--

--------------enigC7B5626D5BBCAB6B37210676
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk9DJEYACgkQEwoGUlJjrt8q0ACgjzCXhdwuNwDBXrWzpOX8lp4O
CrgAoJSsJS/gqSHLUj/Z4ySGOPak+K0z
=uZfU
-----END PGP SIGNATURE-----

--------------enigC7B5626D5BBCAB6B37210676--
