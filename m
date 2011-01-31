From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 31 Jan 2011 03:43:32 +0000
Subject: CCID 2 will increase Congestion Window > Sequence Window
Message-Id: <1296445413.3066.26.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-fYvbCD5GTnuPgk0oOtBl"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-fYvbCD5GTnuPgk0oOtBl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello All,

In doing some DCCP testing, I have identified a bug in the CCID 2
implementation.  Right now, CCID 2 will willingly increase it's
congestion window (the number of packets it tries to keep in the
network) greater than the sequence window.  This, of course, causes
acknowledgments from the receiver to be deemed sequence invalid which
causes a Sync/SyncAck exchange. In at least one test, this has resulted
in a loss of 1/3rd of the bandwidth because of repeated Sync/SyncAck
exchanges. I am working on a patch; however, I am interested to know if
anyone else has seen similar problems and/or is working on a solution...

For reference, I discovered this in testing the effectiveness of CCID 2
by running Iperf tests from a machine connected by a 100Mbit link to a
machine with only a 10Mbit link. I believe the long RTT is caused by
packet queuing in the Linux box that bridges the 100Mbit link to the
10Mbit link and does the packet capture.

Samuel Jero
Internetworking Research Group
Ohio University

--=-fYvbCD5GTnuPgk0oOtBl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1GL+AACgkQEwoGUlJjrt9z+ACgunzD57bAPdSLJ62snGeaI/EK
4SQAn0t9/Y5KDrKy8HRZD4dLqnOtBlVA
=XIV9
-----END PGP SIGNATURE-----

--=-fYvbCD5GTnuPgk0oOtBl--
