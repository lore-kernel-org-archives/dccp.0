From: Samuel Jero <sj323707@ohio.edu>
Date: Wed, 05 Jan 2011 02:52:12 +0000
Subject: Re: Sequence Number Validation Bug Fixes 2/2
Message-Id: <1294195932.3439.405.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-gqjvD+CKAapHNX8vbxQM"
List-Id: <dccp.vger.kernel.org>
References: <1293393024.22785.1.camel@jero-laptop>
In-Reply-To: <1293393024.22785.1.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-gqjvD+CKAapHNX8vbxQM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> | In the case of Sync/SyncAck packets, RFC 4340 section 7.5.4 requires
> | that:
> | "On receiving a sequence-valid DCCP-Sync packet, the peer endpoint
> | (say, DCCP B) MUST update its GSR variable and reply with a DCCP-
> | SyncAck packet.  The DCCP-SyncAck packet's Acknowledgement Number
> | will equal the DCCP-Sync's Sequence Number, which is not necessarily
> | GSR.  Upon receiving this DCCP-SyncAck, which will be sequence-valid
> | since it acknowledges the DCCP-Sync, DCCP A will update its GSR
> | variable, and the endpoints will be back in sync."
> |=20
> | Adding the check for > GSR inside dccp_update_gsr() breaks this
> | requirement.
> |
> I wonder how the requirement breaks, in the above paragraph are several p=
oints:
>  1. it applies only to sequence-valid DCCP-Sync packets,
>  2. need to clarify what "update its GSR variable" means,
>  3. DCCP-SyncAck.ackno =3D DCCP-Sync.seqno (illustrated below),
>  4. case for receiving sequence-valid DCCP-SyncAck analogous to (1), (2).
>=20
<snip>

> With regard to (2), my understanding is that "updating the GSR" or "updat=
ing
> the GAR" (step 6 in RFC 4340, 8.5) means to update the value if it is gre=
ater
> than the previous one but not otherwise.

My initial assumption on reading the RFC was that "updating the GSR"
meant updating the value of GSR in either case. Hence my argument.
However, once you bring up the point, I concede that the statement is
ambiguous.

After further examination of the RFC, I note that the same wording is
used with regard to normal Data/DataAck/Ack packets in 8.5 Step 6 and
that those packets clearly shouldn't reduce the GSR. When combined with
your argument, I am inclined to agree with you.

By the way, your description of the Sync/SyncAck interaction was
extremely helpful. I'll admit that I was struggling to understand
exactly how that worked after reading and rereading the RFC.

> In short, I find that allowing DCCP-Sync(Ack) to move the GSR backwards t=
o
> sequence number below those already received on acknowledgeable packets o=
n
> the same connection creates a complex and counter-intuitive bevaviour whi=
ch
> I think is not warranted (in particular the definition of GSR does no lon=
ger
> mean 'Greatest', but would change into something like "usually the greate=
st
> sequence number received, when a DCCP-Sync arrives, GSR could be up to W/=
4
> below the greatest sequence number received on the connection").

After examining your argument in detail, I have to agree with you.
Allowing the GSR to move backwards is detrimental. Given my above
comment, it is also not required by the RFC. Therefore, I see no reason
to allow it.

>=20
> Please let me know your thoughts, as said I am not going to submit this a=
t this
> stage (it is however in the test tree at the moment).

I am now in agreement with the patch as below.

Samuel Jero
Internetworking Research Group
Ohio University

>=20
> | > >>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<=
<<<<<<<<
> | > dccp: fix bug in updating the GSR
> | >=20
> | > Currently dccp_check_seqno allows any valid packet to update the Grea=
test
> | > Sequence Number Received, even if that packet's sequence number is le=
ss than
> | > the current GSR. This patch adds a check to make sure that the new pa=
cket's
> | > sequence number is greater than GSR.
> | >=20
> | > Signed-off-by: Samuel Jero <sj323707@ohio.edu>
> | > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> | > ---
> | >  net/dccp/dccp.h |    3 ++-
> | >  1 file changed, 2 insertions(+), 1 deletion(-)
> | >=20
> | > --- a/net/dccp/dccp.h
> | > +++ b/net/dccp/dccp.h
> | > @@ -426,7 +426,8 @@ static inline void dccp_update_gsr(struc
> | >  {
> | >  	struct dccp_sock *dp =3D dccp_sk(sk);
> | > =20
> | > -	dp->dccps_gsr =3D seq;
> | > +	if (after48(seq, dp->dccps_gsr))
> | > +		dp->dccps_gsr =3D seq;
> | >  	/* Sequence validity window depends on remote Sequence Window (7.5.=
1) */
> | >  	dp->dccps_swl =3D SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_wi=
n / 4);
> | >  	/*

--=-gqjvD+CKAapHNX8vbxQM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0j3MEACgkQEwoGUlJjrt/zVACeOF05o/Lrqu5y+vaRouhdUnsb
MsEAoIRWU7n3Niq/a1/Y1wtNmOXoFRZm
=TG/f
-----END PGP SIGNATURE-----

--=-gqjvD+CKAapHNX8vbxQM--
