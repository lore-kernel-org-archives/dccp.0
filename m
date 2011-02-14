From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 14 Feb 2011 01:42:21 +0000
Subject: [PATCH 0/4]  dccp: Congestion Window > Sequence Window
Message-Id: <1297647741.9816.143.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-z0D11t8WuaCzKtt9DpGe"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-z0D11t8WuaCzKtt9DpGe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

All,

I have put together a set of patches to fix the bug I reported earlier
where CCID 2 will allow the congestion window to grow larger than the
sequence window.

The first patch inserts a check on the sequence window and ack ratio
(and hence remote sequence window) to avoid increasing the congestion
window larger than the sequence window. It also adds code to increase
the sequence window and ack ratio as necessary.

The second patch fixes an issue in the feature negotiation code where
Confirm options are retransmitted forever.

The third patch fixes an issue in the feature negotiation code where
DCCP would reset the connection on a Confirm for a value of an NN option
other than the most recent. The RFCs imply that such an option should
just be ignored. Further, this causes a connection reset if the value of
an NN option changes twice in under two RTTs.

The fourth, and final patch, enables the Ack Ratio option so that we can
use it. The option had been disabled because the congestion control on
the acks in CCID 2 is broken. However, the patch also disables sending
Ack Ratio options because of congestion control on the acks to prevent
that from causing problems.
While I didn't notice any problems when I ran DCCP with the Ack
Congestion Control Enabled, I have not tested that part of the code
throughly, so I chose to leave it disabled in this patch set.


Samuel Jero
Internetworking Research Group
Ohio University


--=-z0D11t8WuaCzKtt9DpGe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1YiFIACgkQEwoGUlJjrt8HMwCghYXb0/8nqe741t8es0tpDC/Q
MPcAn1RIh22vqwsGFQ8PjTPXlgqN2TPa
=EoKH
-----END PGP SIGNATURE-----

--=-z0D11t8WuaCzKtt9DpGe--
