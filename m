From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 16 Jul 2011 17:43:30 +0000
Subject: Re: [PATCH 01/07] dccp: support for the exchange of NN options in
Message-Id: <4E21CDC2.6070505@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enigEA1E4BCEDE80ABFF9269A752"
List-Id: <dccp.vger.kernel.org>
References: <1310650955-5159-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1310650955-5159-2-git-send-email-gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org

--------------enigEA1E4BCEDE80ABFF9269A752
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

You have my signed-off-by for this patch.

I'm not clear if you intend to use this top commit message for the
entire patch, if so, see comment below.

> In contrast to static feature negotiation at the begin of a connection,=
 which
> establishes the capabilities of both endpoints, this patch introduces s=
upport
> for dynamic exchange of feature negotiation options.
>=20
> Such a dynamic exchange is necessary in at least two cases:
>  * CCID-2's Ack Ratio (RFC 4341, 6.1.2) which changes during the connec=
tion;
>  * Sequence Window values that, as per RFC 4340, 7.5.2, should be sent =
"as
>    as the connection progresses".
>=20
> Both are NN (non-negotiable) features. Hence dynamic feature "negotiati=
on" is
> distinguished from static/pre-connection negotiation by the following:
>  * no new capabilities are negotiated (those that matter for the connec=
tion
>    are negotiated prior to setting up the connection, comparable to SIP=
);
>  * features must be understood by each endpoint: as per RFC 4340, 6.4,
>    Sequence Window is "Req'd" and Ack Ratio must be understood when CCI=
D-2
>    is used as per the note underneath Table 4.
>=20
> These characteristics are reflected in the implementation:
>  * only NN options can be exchanged after connection setup;

>  * NN options are activated directly after validating them. The rationa=
le is
>    that a peer must accept every valid NN value (RFC 4340, 6.3.2), henc=
e it
>    will either accept the value and send a "Confirm R", or it will send=
 an
>    empty Confirm (which will reset the connection according to FN rules=
).

This statement is confusing. While the receiving side will activate a
immediately, the sender will now wait for the CONFIRM before activating
the new value. This changed as a result of one of the merged patches. I
would recommend leaving this statement out.

>  * An Ack is scheduled directly after activation to accelerate communic=
ating
>    the update to the peer.
>=20
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Signed-off-by: Samuel Jero <sj323707@ohio.edu>


Samuel Jero
Internetworking Research Group
Ohio University


--------------enigEA1E4BCEDE80ABFF9269A752
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4hzcwACgkQEwoGUlJjrt/SSQCgsZGVZQDn145wqWq5t7CP6hBp
uBIAnRR2pKcITItebVH7ftked3KVpv4f
=ezOw
-----END PGP SIGNATURE-----

--------------enigEA1E4BCEDE80ABFF9269A752--
