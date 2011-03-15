From: Samuel Jero <sj323707@ohio.edu>
Date: Tue, 15 Mar 2011 04:53:11 +0000
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
Message-Id: <1300164791.20638.64.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-up0mA8RipvzCOMYowYOh"
List-Id: <dccp.vger.kernel.org>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
To: dccp@vger.kernel.org

--=-up0mA8RipvzCOMYowYOh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> I revised this some more, the function remains the same, but it is shorte=
r=20
> http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=3Ddccp_exp.git;a=3Dc=
ommitdiff;h=3D94da7d70003e8185fe189146f336db72c8fa1f0b
>=20
> (If there is disagreement regarding allowing a get_nn_ function to query =
non-nn
>  features, I will add the test for type =3D=3D NN back in.)

I think the test for NN features should be added back in. If we allow
the function to be called for non-NN features, we need to include more
code to return the correct values for non-NN features. In either the
negotiating or non-negating state, the current code will return bad
values for non-NN features.

Further, since non-NN features are indeterminate until we receive the
confirm, I don't see that a get_ function for those features would ever
be useful.


> | >  1) Since ccid2_ack_ratio_next(sk) is just a wrapper around
> | >     dccp_feat_get_nn_next_val(sk, DCCPF_ACK_RATIO), ok to
> | >     use this instead?
> |=20
> | It's just fine to use dccp_feat_get_nn_next_val() instead. My primary
> | reason for creating ccid2_ack_ratio_next() was to keep line lengths
> | down.
> |=20
> Perhaps a shorter name, e.g.    dccp_feat_nn_get()
> (since it returns either the current or next value, and there is no other
>  accessor function defined).

A shorter name is probably a good idea. dccp_feat_nn_get() seems fine.


> | >  3) There is room for some refactoring:
> | >     a) dccp_feat_signal_nn_change() always implies also in part
> | >        dccp_feat_get_nn_next_val(): if the latter function returns
> | >        the same value as the supposedly 'new' one, it is not
> | >        necessary to start a new negotiation. So all the repeated
> | >        tests could be folded into that function.
> |=20
> | The problem here is that the ack ratio should only be changed after a
> | loss, idle period, etc if the new cwnd is going to be less than the
> | (negotiating) ack ratio. We need to call dccp_feat_get_nn_next_val() to
> | decide whether we need to adjust the ack ratio or not.
> |
> That is a good point, maybe I need to reread the patch again. From what I=
 saw,
> dccp_nn_get_next_val() is so far only called immediately before changing =
the
> value, whereas the above comment hints more at a peek/read-only functiona=
lity.
>=20
> This understanding was also the basis of the attached patch - actually I =
was
> quite happy since its use further simplified the interface.

The patch you attached looks fine.

The additional calls to dccp_nn_get_next_val() are made just before we
call ccid2_change_l_ack_ratio() when we have a loss, idle period, or
application limited period.=20

These are the sections of code that you recommended become a separate
patch. I have re-factored that code slightly to reduce code duplication
and will send out that patch immediately after this email.


> | We don't want to change the ack ratio every time we have a loss, etc.
> | Doing so will result in pointless negotiations and more fluctuations in
> | the ack ratio, neither of which is desirable.
> |=20
> Agree, having done some testing over the weekend I found that some kind o=
f
> hysteresis would be desirable.
>=20
> I don't know if blocking the Ack Ratio code is the reason, but during the
> initial slow-start there were ChangeL requests for Sequence Window on nea=
rly
> every packet, which seems too much.

Right now, Change's are sent on every packet until the matching Confirm
is received. That will be the cause of most of the Change's you are
seeing.

The other thing is that at the beginning of a connection the sequence
window will be reduced and then increased. The initial window of 100
packets is too wide for 5*cwnd at the start of the connection. So the
window will be reduced as low as it will go at the very beginning of the
connection. However, as slow start picks up, cwnd will increase and the
sequence window will as well.

I've seen the above behavior, but haven't thought of an effective
solution (nor am I sure that we need a solution). Capping the minimum
sequence window at the default (100 packets) would solve this, but that
doesn't seem like a great solution.

>=20
> If low_threshold =3D=3D high_threshold, it oscillates. I think you have a=
lready done
> some work on this in the code using CCID2_WIN_CHANGE_FACTOR.

I'm not entirely certain what low_threshold and high_threshold you are
talking about. I have not seen sequence window oscillations other as the
congestion window oscillates in congestion avoidance as is expected.

Samuel Jero
Internetworking Research Group
Ohio University

--=-up0mA8RipvzCOMYowYOh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1+8LMACgkQEwoGUlJjrt8KxACfVbEhgzAfYb+N2iRJDrfB2Kfp
oz4AniTH04AOdXCGkR4lukaSrd+07Ykw
=BYTl
-----END PGP SIGNATURE-----

--=-up0mA8RipvzCOMYowYOh--
