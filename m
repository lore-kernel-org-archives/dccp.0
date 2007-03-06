From: Andre Noll <maan@systemlinux.org>
Date: Tue, 06 Mar 2007 10:20:32 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <20070306102032.GZ22572@skl-net.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="5xr6Gr0irOxp3+3c"
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
To: dccp@vger.kernel.org


--5xr6Gr0irOxp3+3c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09:20, Gerrit Renker wrote:

> thank you for continued testing. I spent a long while yesterday evening i=
solating
> possible causes. Here are further pointers
>=20
> 1. Can you please tell us which kernel you are using?

I checked 2.6.19.x (which works), 2.6.20, 2.6.20.1 and 2.6.21-rc1
(which all have the bug). 2.6.21-rc2 wouldn't compile on my system
due to some apic isssue.

>  If it is a very recent
>    one, can you please check whether you get the following message in your
>    syslog:
>                 "[...] listen_overflow!"
>=20
>    If yes (dccp_debug should be turned on), then very likely setting list=
en(fd, 1)
>    instead of listen(fd,0) may remove any strange effects.=20
>    The reason is a recent change in sk_accept_queue_is_full which causes =
a different
>    treatment of zero-sized listen-accept queues.

Will test this evening and report tomorrow.

> 2. With the most recent davem-2.6 kernel I was not able to reproduce this=
 bug. It=20
>    should, after some more thought, really make no difference whether you=
 are using
>    loopback (127.0.0.1) or not.

I can try this kernel as well. I'm currently downloading

	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
=09
Hope, that's the right one.

> 3. I analyzed the reverted patch you identified. There is indeed a loopho=
le (which
>    has not become visible so far), hence I will send=20
>    (a) an update of this patch=20
>    (b) a second patch to do with timer initialisation of child sockets.
>    In particular (a) may help.=20

OK. Are these patches against the current linus-tree?

> 4. It may be worth trying a different application, e.g.=20
>=20
>        http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/ttcp_dccp.tar.gz =
   =20
>    in order to find out which combination of system calls triggers the bu=
g condition.

Will test and report.


>    I managed to get the paraslash application built, but could not figure=
 out how to
>    populate the user lists and required configuration files.=20

That's explained in the INSTALL file. But you don't need any
configuration files and I _think_ you don't even need a paraslash
user to reproduce the bug, an empty ~/.paraslash/server.users should
do. Just start para_server with the autoplay (-a) option, i.e.

	para_server -a --random_dir=3D/some/dir/containing/an/mp3/file

Then
	para_recv -r dccp

triggers the bug.

>    I don't understand your code fully yet, but with the more recent stack=
 trace I
>    was wondering whether this has to do with setting the listen socket no=
n-blocking
>    (mark_fd_nonblock), which is done both in sender and receiver.

IMHO it's considered good practice to set all fds which are used for
select() to non-blocking mode.  AFAIR the reason is the situation
where a network packet arrives but is discarded because of a checksum
error. In this case it might happen that select() indicates readability
of an fd, but a subsequent read() blocks nevertheless. Maybe it's
unneccesssary to set an fd to non-blocking mode if it is only used
for writing. But it won't hurt either, so..

Thanks
Andre
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--5xr6Gr0irOxp3+3c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFF7UBwWto1QDEAkw8RAj6aAJ9djzWxJjFrEBxt0wUS5LhX1p+W3wCeIyOh
SB3Pn65sCjqyZGYwAg64IMI=
=cXPd
-----END PGP SIGNATURE-----

--5xr6Gr0irOxp3+3c--
