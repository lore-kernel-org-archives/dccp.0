From: Samuel Jero <sj323707@ohio.edu>
Date: Tue, 08 Mar 2011 04:50:31 +0000
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
Message-Id: <1299559831.7569.41.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-/o4tvpKIC/Xr94jPxrUs"
List-Id: <dccp.vger.kernel.org>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
To: dccp@vger.kernel.org

--=-/o4tvpKIC/Xr94jPxrUs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> I am sending this as RFC since I have not yet deeply tested this. It make=
s
> the exchange of NN options in established state conform to RFC 4340, 6.6.=
1
> and thus actually is a bug fix.

I now had a chance to put this patch through extensive tests. I had to
modify two things about the patch to get good performance:
1)CCID2 now checks the congestion window against the currently
negotiating ack ratio value to determine whether to change the ack ratio
after an RTO, an idle period, or a loss. This prevents a problem where
an RTO or loss or idle period occurs and the ack ratio is less than the
congestion window but is in the process of being negotiated larger. That
negotiation will reach the sender on the first packet sent and RTOs will
result.
The primary change is adding a function called
dccp_feat_get_nn_next_val() to feat.c. This function returns the value
of the NN feature indicated that is is the process of being negotiated.
If the feature is not being negotiated, then the current value is
returned.
2)In a situation where the ack ratio has to be reduced because of an
RTO, idle period, or loss, CCID2 now sets the ack ratio to half of the
congestion window (or 1 if that's zero) instead of to the congestion
window. This should reduce the problems if one ack is lost (we have to
lose two acks to not acknowledge an entire congestion window and trigger
RTO)

Below is an improved patch. What are your thoughts on these changes?

Samuel Jero
Internetworking Research Group
Ohio University


>>>>>>>>>>>>>>>>>>>>>>>>>Patch<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: Only activate NN values after receiving the Confirm option

This defers changing local values using exchange of NN options in
established connection state by only activating the value after
receiving the Confirm option, as mandated by RFC 4340, 6.6.1.

Signed-off-by: Samuel Jero
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -83,9 +82,13 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, stru=
ct sk_buff *skb)
 	return CCID_PACKET_SEND_AT_ONCE;
 }
=20
+static __u64 ccid2_ack_ratio_next(struct sock *sk)
+{
+	return dccp_feat_get_nn_next_val(sk, DCCPF_ACK_RATIO);
+}
+
 static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 {
-	struct dccp_sock *dp =3D dccp_sk(sk);
 	u32 max_ratio =3D DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->tx_cwnd, 2);
=20
 	/*
@@ -101,11 +104,10 @@ static void ccid2_change_l_ack_ratio(struct sock *sk,=
 u32 val)
 	if (val > DCCPF_ACK_RATIO_MAX)
 		val =3D DCCPF_ACK_RATIO_MAX;
=20
-	if (val =3D=3D dp->dccps_l_ack_ratio)
+	if (val =3D=3D ccid2_ack_ratio_next(sk))
 		return;
=20
 	ccid2_pr_debug("changing local ack ratio to %u\n", val);
-	dp->dccps_l_ack_ratio =3D val;
 	dccp_feat_signal_nn_change(sk, DCCPF_ACK_RATIO, val);
 }
=20
@@ -117,11 +119,9 @@ static void ccid2_change_l_seq_window(struct sock *sk,=
 u64 val)
 		val =3D DCCPF_SEQ_WMIN;
 	if (val > DCCPF_SEQ_WMAX)
 		val =3D DCCPF_SEQ_WMAX;
-	if (val =3D=3D dp->dccps_l_seq_win)
-		return;
=20
-	dp->dccps_l_seq_win =3D val;
-	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);
+	if (val !=3D dp->dccps_l_seq_win)
+		dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);
 }
=20
 static void ccid2_hc_tx_rto_expire(unsigned long data)
@@ -203,6 +203,10 @@ static void ccid2_cwnd_application_limited(struct sock=
 *sk, const u32 now)
 	}
 	hc->tx_cwnd_used  =3D 0;
 	hc->tx_cwnd_stamp =3D now;
+
+	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
+	if (ccid2_ack_ratio_next(sk) > hc->tx_cwnd)
+		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
 }
=20
 /* This borrows the code of tcp_cwnd_restart() */
@@ -221,6 +225,10 @@ static void ccid2_cwnd_restart(struct sock *sk, const =
u32 now)
=20
 	hc->tx_cwnd_stamp =3D now;
 	hc->tx_cwnd_used  =3D 0;
+
+	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
+	if (ccid2_ack_ratio_next(sk) > hc->tx_cwnd)
+		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
 }
=20
 static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
@@ -491,8 +531,8 @@ static void ccid2_congestion_event(struct sock *sk, str=
uct ccid2_seq *seqp)
 	hc->tx_ssthresh  =3D max(hc->tx_cwnd, 2U);
=20
 	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
-	if (dccp_sk(sk)->dccps_l_ack_ratio > hc->tx_cwnd)
-		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd);
+	if (ccid2_ack_ratio_next(sk) > hc->tx_cwnd)
+		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
 }
=20
 static int ccid2_hc_tx_parse_options(struct sock *sk, u8 packet_type,
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 26cba68..e8cf5a7 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -491,6 +491,7 @@ static inline int dccp_ack_pending(const struct sock *s=
k)
 }
=20
 extern int  dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_va=
l);
+extern __u64 dccp_feat_get_nn_next_val(struct sock *sk, u8 feat);
 extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
 extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *d=
req);
 extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_s=
ock*,
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 9a8c2ba..bc26f33 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -775,12 +775,7 @@ int dccp_feat_register_sp(struct sock *sk, u8 feat, u8=
 is_local,
  * @sk: DCCP socket of an established connection
  * @feat: NN feature number from %dccp_feature_numbers
  * @nn_val: the new value to use
- * This function is used to communicate NN updates out-of-band. The differ=
ence
- * to feature negotiation during connection setup is that values are activ=
ated
- * immediately after validation, i.e. we don't wait for the Confirm: eithe=
r the
- * value is accepted by the peer (and then the waiting is futile), or it i=
s not
- * (Reset or empty Confirm). We don't accept empty Confirms - transmitted =
values
- * are validated, and the peer "MUST accept any valid value" (RFC 4340, 6.=
3.2).
+ * This function is used to communicate NN updates out-of-band.
  */
 int dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val)
 {
@@ -805,9 +800,6 @@ int dccp_feat_signal_nn_change(struct sock *sk, u8 feat=
, u64 nn_val)
 		dccp_feat_list_pop(entry);
 	}
=20
-	if (dccp_feat_activate(sk, feat, 1, &fval))
-		return -EADV;
-
 	inet_csk_schedule_ack(sk);
 	return dccp_feat_push_change(fn, feat, 1, 0, &fval);
 }
@@ -1356,6 +1348,9 @@ static u8 dccp_feat_handle_nn_established(struct sock=
 *sk, u8 mandatory, u8 opt,
 		if (fval.nn !=3D entry->val.nn)
 			return 0;
=20
+		/* Only activate after receiving the Confirm option (6.6.1). */
+		dccp_feat_activate(sk, feat, local, &fval);
+
 		/* It has been confirmed - so remove the entry */
 		dccp_feat_list_pop(entry);
=20
@@ -1374,6 +1369,39 @@ fast_path_failed:
 			 : DCCP_RESET_CODE_OPTION_ERROR;
 }
=20
+/*
+* dccp_feat_get_nn_next_val  -  Get the currently negotiating value of an =
NN
+*				feature. If the feature isn't being currently
+*				negotiated, return it's current value.
+* @sk: DCCP socket of an established connection
+* @feat: NN feature number from %dccp_feature_numbers
+*/
+__u64 dccp_feat_get_nn_next_val(struct sock *sk, u8 feat)
+{
+	struct list_head *fn =3D &dccp_sk(sk)->dccps_featneg;
+	struct dccp_feat_entry *entry;
+	u8 type =3D dccp_feat_type(feat);
+
+	if (type =3D=3D FEAT_UNKNOWN || type !=3D FEAT_NN)
+		return 0;
+
+	entry =3D dccp_feat_list_lookup(fn, feat, 1);
+	if (entry !=3D NULL)
+		return entry->val.nn;
+
+	switch (feat) {
+	case DCCPF_ACK_RATIO:
+		return dccp_sk(sk)->dccps_l_ack_ratio;
+	case DCCPF_SEQUENCE_WINDOW:
+		return dccp_sk(sk)->dccps_l_seq_win;
+	default:
+		dccp_pr_debug("Attempting to get value \
+						for unknown NN feature");
+	}
+return 0;
+}
+EXPORT_SYMBOL_GPL(dccp_feat_get_nn_next_val);
+
 /**
  * dccp_feat_parse_options  -  Process Feature-Negotiation Options
  * @sk: for general use and used by the client during connection setup

--=-/o4tvpKIC/Xr94jPxrUs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk11tZMACgkQEwoGUlJjrt+5zACgqNiFXQLkhLt8cjTOPn4oBbwp
Bj4An1wxJRosEG72o5Edmp5pyrp30yyA
=BtTY
-----END PGP SIGNATURE-----

--=-/o4tvpKIC/Xr94jPxrUs--
