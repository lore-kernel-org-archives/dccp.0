From: Samuel Jero <sj323707@ohio.edu>
Date: Thu, 30 Dec 2010 20:56:58 +0000
Subject: Re: Sequence Number Validation Bug Fixes 2/2
Message-Id: <1293742618.22785.112.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-EaBvJh0HATkw4p1c8XNl"
List-Id: <dccp.vger.kernel.org>
References: <1293393024.22785.1.camel@jero-laptop>
In-Reply-To: <1293393024.22785.1.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-EaBvJh0HATkw4p1c8XNl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Gerrit,
> | --- a/net/dccp/input.c
> | +++ b/net/dccp/input.c
> | @@ -252,7 +253,10 @@ static int dccp_check_seqno(struct sock *sk, struc=
t
> | sk_buff *skb)
> | if (between48(seqno, lswl, dp->dccps_swh) &&
> |     (ackno =3D=3D DCCP_PKT_WITHOUT_ACK_SEQ ||
> |      between48(ackno, lawl, dp->dccps_awh))) {
> | - dccp_update_gsr(sk, seqno);
> | +
> | + if(after48(seqno, dp->dccps_gsr)){
> | + dccp_update_gsr(sk, seqno);
> | + }
> |=20
> | if (dh->dccph_type !=3D DCCP_PKT_SYNC &&
> |     ackno !=3D DCCP_PKT_WITHOUT_ACK_SEQ &&=20
>=20
> I would like to move that change from dccp_check_seqno() into
> dccp_update_gsr(), since the latter function is also called for Sync/Sync=
Ack
> packets, where the same problem exists.

In the case of Sync/SyncAck packets, RFC 4340 section 7.5.4 requires
that:
"On receiving a sequence-valid DCCP-Sync packet, the peer endpoint
(say, DCCP B) MUST update its GSR variable and reply with a DCCP-
SyncAck packet.  The DCCP-SyncAck packet's Acknowledgement Number
will equal the DCCP-Sync's Sequence Number, which is not necessarily
GSR.  Upon receiving this DCCP-SyncAck, which will be sequence-valid
since it acknowledges the DCCP-Sync, DCCP A will update its GSR
variable, and the endpoints will be back in sync."

Adding the check for > GSR inside dccp_update_gsr() breaks this
requirement.

Further, Sync/SyncAck packets are already checked for sequence validity
by dccp_check_seqno() before the call to dccp_update_gsr(). The checks
used follow RFC 4340 section 7.5.3:
DCCP-Sync        SWL <=3D seqno             AWL <=3D ackno <=3D AWH
DCCP-SyncAck     SWL <=3D seqno             AWL <=3D ackno <=3D AWH


As such, I would leave the check in dccp_check_seqno(). Alternatively,
it could be moved to dccp_update_gsr() and a further check for not
Sync/SyncAck included.

Samuel Jero
Internetworking Research Group
Ohio University
>=20
> The edited patch is below -- please have a look. This allows to safely ca=
ll
> dccp_update_gsr() without moving the window backwards. Calling that funct=
ion
> may be required not only when GSR changes, but also when the Sequence Win=
dow
> value is updated, which requires to update the SWL/SWH boundaries.
>=20
>=20
> >>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<=
<<<<
> dccp: fix bug in updating the GSR
>=20
> Currently dccp_check_seqno allows any valid packet to update the Greatest
> Sequence Number Received, even if that packet's sequence number is less t=
han
> the current GSR. This patch adds a check to make sure that the new packet=
's
> sequence number is greater than GSR.
>=20
> Signed-off-by: Samuel Jero <sj323707@ohio.edu>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/dccp.h |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -426,7 +426,8 @@ static inline void dccp_update_gsr(struc
>  {
>  	struct dccp_sock *dp =3D dccp_sk(sk);
> =20
> -	dp->dccps_gsr =3D seq;
> +	if (after48(seq, dp->dccps_gsr))
> +		dp->dccps_gsr =3D seq;
>  	/* Sequence validity window depends on remote Sequence Window (7.5.1) *=
/
>  	dp->dccps_swl =3D SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_win / =
4);
>  	/*

--=-EaBvJh0HATkw4p1c8XNl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0c8hYACgkQEwoGUlJjrt8Q6wCcDKdFZPattySnSDhB7MVnulez
02AAn0U2r7zDCvmaO8N37bfjgCgN1mTk
=yW6u
-----END PGP SIGNATURE-----

--=-EaBvJh0HATkw4p1c8XNl--
