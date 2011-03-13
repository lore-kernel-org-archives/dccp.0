From: Samuel Jero <sj323707@ohio.edu>
Date: Sun, 13 Mar 2011 20:34:57 +0000
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
Message-Id: <1300048497.31664.158.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-7KgV/HWSe59bxYmzFkyy"
List-Id: <dccp.vger.kernel.org>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
To: dccp@vger.kernel.org

--=-7KgV/HWSe59bxYmzFkyy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> Well done, this looks good. I did some minor editing:
>  * whitespace/formatting/comments,
>  * simplification/subsumption,
>  * function should not be called for non-NN or non-known
>    feature, hence turned that into a DCCP_BUG() condition.

Okay

>=20
> | 2)In a situation where the ack ratio has to be reduced because of an
> |    RTO, idle period, or loss, CCID-2 now sets the ack ratio to half of =
the
> |    congestion window (or 1 if that's zero) instead of to the congestion
> |    window. This should reduce the problems if one ack is lost (we have =
to
> |    lose two acks to not acknowledge an entire congestion window and tri=
gger
> |    RTO)
> |=20
> I think this makes for a separate patch, and it would be good to commenti=
fy
> the above into the code; please also see 3(b) below.

Separate patch coming shortly. Will add comment describing the
situation.

> Some work still remains to be done:
>=20
>  1) Since ccid2_ack_ratio_next(sk) is just a wrapper around
>     dccp_feat_get_nn_next_val(sk, DCCPF_ACK_RATIO), ok to
>     use this instead?

It's just fine to use dccp_feat_get_nn_next_val() instead. My primary
reason for creating ccid2_ack_ratio_next() was to keep line lengths
down.

>  2) Analogously, for the local sequence window feature the
>     dccp_feat_get_nn_next_val() is not used, it uses the
>     current value:
>     if (val !=3D dp->dccps_l_seq_win)
> 	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);

That should also be updated to use dccp_feat_get_nn_next_val(sk,
DCCPF_SEQUENCE_WINDOW)

>  3) There is room for some refactoring:
>     a) dccp_feat_signal_nn_change() always implies also in part
>        dccp_feat_get_nn_next_val(): if the latter function returns
>        the same value as the supposedly 'new' one, it is not
>        necessary to start a new negotiation. So all the repeated
>        tests could be folded into that function.


The problem here is that the ack ratio should only be changed after a
loss, idle period, etc if the new cwnd is going to be less than the
(negotiating) ack ratio. We need to call dccp_feat_get_nn_next_val() to
decide whether we need to adjust the ack ratio or not.

We don't want to change the ack ratio every time we have a loss, etc.
Doing so will result in pointless negotiations and more fluctuations in
the ack ratio, neither of which is desirable.

>     b) The following pattern appears three times in ccid2.c:
> 	if (ccid2_ack_ratio_next(sk) > hc->tx_cwnd)
> 		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
>        Perhaps this can, as some other parts of this patch set, be
>        refactored (e.g. the CCID-2 part is already a separate patch).

I'll create a function for this code. Coming in separate patch.
>=20
> Other than the minor edits I have left your patch as is, i.e. I have
> not yet performed changes (1) and (2), awaiting your opinion on that.

Go ahead with 1) and 2).  I'll send out a new patch for 3 (b) shortly.

Samuel Jero
Internetworking Research Group
Ohio University

--=-7KgV/HWSe59bxYmzFkyy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk19Km4ACgkQEwoGUlJjrt9b/gCfcMIlQTaopjZLL8P1d2CT7ova
w3YAn0XmFq3oZlzJ1HAbuaik4vE9rX6v
=pLWv
-----END PGP SIGNATURE-----

--=-7KgV/HWSe59bxYmzFkyy--
