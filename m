From: Samuel Jero <sj323707@ohio.edu>
Date: Fri, 14 Jan 2011 18:41:51 +0000
Subject: Re: Sequence Number Validation Bug Fixes 0/2
Message-Id: <1295030512.3000.17.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-ziWPS2LrDtPoYiM7shrT"
List-Id: <dccp.vger.kernel.org>
References: <1293392426.3801.234.camel@jero-laptop>
In-Reply-To: <1293392426.3801.234.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-ziWPS2LrDtPoYiM7shrT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> |=20
> | What I'm noticing is that the DCCP sender doesn't update it's ack
> | numbers very often. In examining packet captures, it is typical for DCC=
P
> | to send 20-60 packets with the same ack number (If I increase the ack
> | and seq validity windows to 1000, I've seen 200 packets with the same
> | ack number).
> |=20
> Depending on the type of link (duplex or half-duplex as in WiFi) and the=
=20
> application sending rate, this might even be normal.

Good point. I hadn't thought of checking whether the network was running
duplex or half-duplex. It turns out that it was running half-duplex
because I had a dumb hub in the testbed setup.=20

Once I adjusted the testbed setup to remove the hub, I was able to run
full duplex and DCCP started to work much better. I'm now seeing an
increase in the ack number with almost every packet(which is what I
would expect to see).=20

Right now, I'm seeing speeds of 9.43Mbits/sec over a 10Mbit/sec link and
85Mbit/sec over a 100Mbit/sec link (TCP does 91Mbit/sec). Those speeds
seem very reasonable and are much better than anything I have seen yet
in working with DCCP. Is that about what I should expect to get out of
DCCP? Or is it typical to get better performance than that?

Samuel Jero
Internetworking Research Group
Ohio University

--=-ziWPS2LrDtPoYiM7shrT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0wmOsACgkQEwoGUlJjrt8eVQCcCX22QZvcr1aCLEzrUU1uZVdP
xN8An2UDfmK9nazMQQmM0tEF7cUfuJcs
=yMOd
-----END PGP SIGNATURE-----

--=-ziWPS2LrDtPoYiM7shrT--
