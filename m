From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 13 Jun 2011 16:15:36 +0000
Subject: Testing Tree Timeline
Message-Id: <4DF637A8.5090104@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enigFA45B0FAD8400035467C4B73"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--------------enigFA45B0FAD8400035467C4B73
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello All,

I was wondering what the current timeline looks like for integrating the
patches in the testing tree into the mainline kernel?

Myself, and several other researchers at Ohio University, believe that
DCCP would be an ideal protocol for encapsulating Delay Tolerant
Networking protocols for transportation across the Internet. For testing
purposes, we do not desire guaranteed reliability, but do require
congestion control.

After testing (and bug fixing) DCCP for most of the last year, we are
convinced that DCCP with CCID2 will be effective for our goals. In fact,
we are in the process of writing an Internet Draft to recommend that
other researchers use DCCP for encapsulating these DTN protocols.

However, the CCID2 code in the mainline kernel is very buggy and suffers
from very poor performance. As a result, the only way to get a version
of CCID2 that works well is to build a custom kernel from the testing
tree. This, obviously, puts a damper on adoption.

As a result, it would be nice to have some idea of when code typically
migrates from the testing tree into the mainline kernel and how that
determination is made.

Thanks.

Samuel Jero
Internetworking Research Group
Ohio University


--------------enigFA45B0FAD8400035467C4B73
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk32N7UACgkQEwoGUlJjrt+o0wCfWKtu+F3hCal8ljaCn3swi3L1
9YsAn1GpQ4lXjxhCIkX43UZVjZCmT0Lz
=276l
-----END PGP SIGNATURE-----

--------------enigFA45B0FAD8400035467C4B73--
