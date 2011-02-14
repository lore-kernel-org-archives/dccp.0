From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 14 Feb 2011 01:49:06 +0000
Subject: Proposed NN Feature handling modification
Message-Id: <1297648146.9816.149.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-yBN+aVExk7tOSU+nafBb"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-yBN+aVExk7tOSU+nafBb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

All,

In putting together the set of patches that I just submitted, I noticed
a less than desirable by-product of the way NN features are currently
handled. However, the reasons for handling them in this way are spelled
out in one of the function comments, so before submitted a patch to
change that, I figured I should throw my findings out on the list.

Right now, the the sender starts using the new value for an NN option as
soon as that option is sent (really, as soon as
dccp_feat_signal_nn_change is called). The justification presented in a
comment is as follows: "values are activated immediately after
validation, i.e. we don't wait for the Confirm: either the value is
accepted by the peer (and then the waiting is futile), or it is not
(Reset or empty Confirm). We don't accept empty Confirms - transmitted
values are validated, and the peer "MUST accept any valid value" (RFC
4340, 6.3.2)."

However, what I have noticed is that this causes a potential problem
with the Ack Ratio Feature. Specifically, this means that for 1/2 RTT
the sender thinks each Ack represents a different number of packets than
the receiver actually means each ack to represent. This is the time
during which that feature negotiation travels between the sender and the
receiver.

In practice, the Appropriate Byte Counting implemented in CCID 2
prevents any real problem, but a similar situation could crop up with
other NN options.

My recommendation is to wait until the Confirm has been received to
alter the value of an NN feature. This eliminates the problem above and
has the advantage that it follows RFC 4340 (section 6.6.1). Further,
making this change should require little code change.

Comments?


Samuel Jero
Internetworking Research Group
Ohio University


--=-yBN+aVExk7tOSU+nafBb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1Yig0ACgkQEwoGUlJjrt9PKQCfRc4t/TSQzeEQM1x6yRxF029q
ousAoLwsKw1Ch5k63lvzoMXQ21Iy6J46
=IAaF
-----END PGP SIGNATURE-----

--=-yBN+aVExk7tOSU+nafBb--
