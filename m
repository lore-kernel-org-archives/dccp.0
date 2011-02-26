From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 26 Feb 2011 02:15:53 +0000
Subject: [PATCH 5/4] dccp:  Always Send Newest NN Feature Value
Message-Id: <1298686553.11418.70.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-8Sw8QenM7+SLI3h3Ba/E"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-8Sw8QenM7+SLI3h3Ba/E
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

At the moment, the DCCP feature negotiation code will ignore a CCID
request to change an NN feature value if a negotiation for that feature
is already underway. This patch changes that behavior to always accept
and negotiate the value from a CCID. This aligns with RFC 4340 6.6.3 and
prevents a nasty bug described below.

I have observed the current behavior to cause problems when the sending
application goes idle in the middle of negotiating a new Ack Ratio value
(CCID 2). When the application starts sending again, CCID 2 will reset
the congestion window to much smaller value. If this value is less than
the Ack Ratio, CCID 2 will attempt to change the Ack Ratio. CCID 2 will
successfully set the local Ack Ratio variable, but the Feature
Negotiation code not send the new value because the Ack Ratio is in the
process of being changed. This causes perpetual RTO timeouts from which
the connection will never recover.

---

This patch should have been included with the initial set of 4 since it
is a result of enabling feature negotiation. However,the testing I did
for those 4 consisted solely of Iperf. Since, it never has pauses in the
data stream, I didn't notice this bug.=20

I have spent most of this week testing these changes using an
application that does have idle periods in the data stream (in addition
to Iperf). As a result, this bug only came to light after I had
submitted those four patches.

My apologies for not testing my patches better...=20

Samuel Jero
Internetworking Research Group
Ohio University

---
Signed-off-by: Samuel Jero
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -797,13 +797,8 @@ int dccp_feat_signal_nn_change(struct sock *sk, u8 fea=
t, u64 nn_val)
 		return -EINVAL;
=20
 	entry =3D dccp_feat_list_lookup(fn, feat, 1);
-	if (entry !=3D NULL) {
-		dccp_pr_debug("Ignoring %llu, entry %llu exists in state %s\n",
-			      (unsigned long long)nn_val,
-			      (unsigned long long)entry->val.nn,
-			      dccp_feat_sname[entry->state]);
+	if (entry && entry->val.nn =3D=3D fval.nn)
 		return 0;
-	}

        if (dccp_feat_activate(sk, feat, 1, &fval))
                return -EADV;


--=-8Sw8QenM7+SLI3h3Ba/E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1oYlUACgkQEwoGUlJjrt9clwCgir1CpdFqBxp4cnocbFyFMEN2
fm4An0q8Pju+aXUhMdMplPXi9ni206e5
=B5cx
-----END PGP SIGNATURE-----

--=-8Sw8QenM7+SLI3h3Ba/E--
