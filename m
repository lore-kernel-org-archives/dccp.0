From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 26 Feb 2011 02:09:38 +0000
Subject: Re: [PATCH 2/4] dccp: Send Confirm Options Only Once
Message-Id: <1298686178.11418.62.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-nO9BNoepYU/3U0eKevsd"
List-Id: <dccp.vger.kernel.org>
References: <1297647877.9816.145.camel@jero-laptop>
In-Reply-To: <1297647877.9816.145.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-nO9BNoepYU/3U0eKevsd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

If a connection is in the OPEN state, then remove Feature Negotiation
Confirm Options from the list of options to send after they are sent
once. Confirm options are NOT supposed to be retransmitted and are ONLY
supposed to be sent in response to a Change Option (RFC 4340 6.2).

When combined with feature negotiation code that would reset the
connection on an feature negotiation value that didn't match the most
recently sent value, this issue will cause a connection reset on the
second feature negotiation for any given NN feature.

Note: Patch #3 (Don't Reset on Confirm for Old NN Feature Values), fixed
the other side of this issue by ignoring values that don't match the
most recent.

---=20

I have modified this patch to only remove confirm options when the
connection is in the OPEN state. This will allow confirm options to be
retransmitted during PARTOPEN to provide durability at that point.

Samuel Jero

---
Signed-off-by: Samuel Jero
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -690,11 +678,22 @@ int dccp_feat_insert_opts(struct dccp_sock *dp, struc=
t dccp_request_sock *dreq,
 			return -1;
 		if (pos->needs_mandatory && dccp_insert_option_mandatory(skb))
 			return -1;
-		/*
-		 * Enter CHANGING after transmitting the Change option (6.6.2).
-		 */
-		if (pos->state =3D=3D FEAT_INITIALISING)
-			pos->state =3D FEAT_CHANGING;
+
+		if (skb->sk->sk_state =3D=3D DCCP_OPEN &&
+			(opt =3D=3D DCCPO_CONFIRM_R || opt =3D=3D DCCPO_CONFIRM_L)) {
+			/*
+			 * Confirms don't get retransmitted (6.6.3) once the
+			 * connection is in state OPEN
+			 */
+			dccp_feat_list_pop(pos);
+		} else {
+			/*
+			 * Enter CHANGING after transmitting the Change
+			 * option (6.6.2).
+			 */
+			if (pos->state =3D=3D FEAT_INITIALISING)
+				pos->state =3D FEAT_CHANGING;
+		}
 	}
 	return 0;
 }

--=-nO9BNoepYU/3U0eKevsd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1oYN4ACgkQEwoGUlJjrt9ZWACgjGa9nbYhlBBxuBSp5Zb10l2R
QAAAoJS1T7CrswP11pwi/S/eYi0ApB9O
=wG9z
-----END PGP SIGNATURE-----

--=-nO9BNoepYU/3U0eKevsd--
