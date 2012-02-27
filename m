From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 27 Feb 2012 05:33:13 +0000
Subject: Re: [PATCH] Allow Acknowledgment of all valid Response packets
Message-Id: <4F4B1599.5000700@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enig854D2038B9AEA529E6D784C0"
List-Id: <dccp.vger.kernel.org>
References: <4F33555B.6070607@ohio.edu>
In-Reply-To: <4F33555B.6070607@ohio.edu>
To: dccp@vger.kernel.org

--------------enig854D2038B9AEA529E6D784C0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

> I have had time to go over the patch. Thanks a lot for submitting it, t=
he previous
> implementation was indeed not correct. I made a few small updates, addi=
ng comments
> and between48(), please have a look at=20
>     http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=3Ddccp_exp.git=
;a=3Dcommitdiff;h=3D2526d0c75d6ef8b5bf4bb326155b03d9cc727610

Looks good. Good catch on the between48()'s.

Samuel Jero
Internetworking Research Group
Ohio University



--------------enig854D2038B9AEA529E6D784C0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk9LFZkACgkQEwoGUlJjrt+KbgCgsXK7bDulPAl9+t8NUsYV+yBZ
NOsAoJ3sezXSIRRYwj4MQKlNvTYcsCo3
=vacn
-----END PGP SIGNATURE-----

--------------enig854D2038B9AEA529E6D784C0--
