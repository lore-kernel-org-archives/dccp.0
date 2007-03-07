From: Andre Noll <maan@systemlinux.org>
Date: Wed, 07 Mar 2007 09:24:21 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <20070307092421.GB22572@skl-net.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="aEcIyhw0mmnxygNd"
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
To: dccp@vger.kernel.org


--aEcIyhw0mmnxygNd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 07:13, Gerrit Renker wrote:

> honestly, I have been unable to reproduce the bug, but there is a point
> in what you said regarding the CCID-split patch. In fact, you identified
> a real bug.
>=20
> I have looked at your application:
>  * the server listens, accepts and=20
>  * then writes to the client
>=20
> This is bi-directional mode. In TCP no problem. In DCCP that patch
> has disabled bidirectional mode since at that time there were
> strange interactions.

This explains why the bug is also present in yesterday's Davem's tree,
even with your two patches from yesterday applied.

> In short: the only mode that is currently supported is
>  * server listens, accepts
>  * and only reads
>  o client connects and
>  o only writes
>=20
> That works with the test applications (ttcp and iperf) since this is
> exactly the way they operate. But it constrains socket programming.

Yes, I tried yesterday to reproduce the bug with ttcp but wasn't able
to do so.

> Can you confirm that, when the `culprit' patch is reverted (as per
> the first email), the bug disappears?

I double-checked this before sending the first mail, but I also will
try the patch you sent today and report tomorrow.

> In any way, thanks a lot for identifying this obvious restriction,
> this has been a great help.

You're welcome.

> I think it is great that real applications appear and I would like to
> use this paraslash application.

Feel free to ask questions, or send patches :)

> If there are any other problems, please
> do email to this list.

Will do. This was really the first problem I had with dccp. I
implemented paraslash's dccp sender/receiver in March 2006 and it
worked very well from the first day on. There have been only minor
changes to this code since then.

Andre
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--aEcIyhw0mmnxygNd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFF7oTFWto1QDEAkw8RArd3AJ9TenGudg7YdSYL16lNyaABWZTuqACgm4Gu
JmjYQ4XccxR3qkvm4cDR0/0=
=wZ7x
-----END PGP SIGNATURE-----

--aEcIyhw0mmnxygNd--
