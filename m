From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 26 Feb 2011 02:10:30 +0000
Subject: Re: [PATCH 4/4] dccp: Enable the Ack Ratio Feature but keep CCID2
Message-Id: <1298686230.11418.64.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-/GzqECZwHO9N9kzN9OuU"
List-Id: <dccp.vger.kernel.org>
References: <1297648018.9816.147.camel@jero-laptop>
In-Reply-To: <1297648018.9816.147.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-/GzqECZwHO9N9kzN9OuU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

>  c int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
> |  {
> | -#ifndef __CCID2_COPES_GRACEFULLY_WITH_DYNAMIC_ACK_RATIO_UPDATES__
> | -	/*
> | -	 * FIXME: This is required until several problems in the CCID-2 code =
are
> | -	 * resolved. The CCID-2 code currently does not cope well; using dyna=
mic
> | -	 * Ack Ratios greater than 1 caused instabilities. These were manifes=
t
> | -	 * in hangups and long RTO timeouts (1...3 seconds). Until this has b=
een
> | -	 * stabilised, it is safer not to activate dynamic Ack Ratio changes.
> | -	 */
> | -	dccp_pr_debug("Not changing %s Ack Ratio from 1 to %u\n",
> | -		      rx ? "RX" : "TX", (u16)ratio);
> | -	ratio =3D 1;
> | -#endif
> |  	if (rx)
> |  		dccp_sk(sk)->dccps_r_ack_ratio =3D ratio;
> |  	else
> |=20
> This also affects the remote ack ratio in ccid2_hc_rx_packet_recv() -- di=
d you observe any=20
> interactions with that?

Since this patch changes the remote ack ratio, that obviously causes
ccid2_hc_rx_packet_recv() to change how often it sends acks. (which is
the point)

Fortunately, ccid2_hc_rx_packet_recv() is very simple and does exactly
what it should if the ack ratio changes: it immediately switches to
using the new value.

This is exactly what we need if the congestion window is very small (say
1 packet). To wait for another cycle of the current ack ratio (i.e. to
switch right after sending an ack), would very likely cause timeouts.

Samuel Jero
Internetworking Research Group
Ohio University=20

--=-/GzqECZwHO9N9kzN9OuU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1oYRIACgkQEwoGUlJjrt8FRgCfeosWmcng6prMXk7jujUOx++/
YpgAoIg37UE9LwJUwp8ZA6Bz9NifpAbg
=tZoY
-----END PGP SIGNATURE-----

--=-/GzqECZwHO9N9kzN9OuU--
