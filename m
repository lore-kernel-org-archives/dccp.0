From: Samuel Jero <sj323707@ohio.edu>
Date: Tue, 22 Mar 2011 01:49:03 +0000
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
Message-Id: <4D88000F.80704@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enigEE9D2D32C7F44E6361E34BBD"
List-Id: <dccp.vger.kernel.org>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
To: dccp@vger.kernel.org

--------------enigEE9D2D32C7F44E6361E34BBD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

> I have revised the patch set addressing the following comments of this =
thread:
>=20
>  1) Renamed function to dccp_feat_nn_get().
>  2) Added test to ensure that function is called for NN
>     features back in.
>  3) Replaced ccid2_ack_ratio_next() with calls to that
>     function (dccp_feat_nn_get(sk, DCCPF_ACK_RATIO)).
>  4) Replaced check for dccps_l_seq_win in ccid2_change_l_seq_window=20
>     with call to dccp_feat_nn_get(sk, DCCPF_SEQUENCE_WINDOW)
>     (for similar calls see separate, attached patch).
>  5) De-inlined ccid2_ack_ratio_next() wrapper as discussed.
>  6) Updated remaining patches with regard to 1-4.

Patch Set looks good except for the very last one ("replace remaining
references to local Sequence Window value"). See below for comments
about that patch.


> | > If low_threshold =3D=3D high_threshold, it oscillates. I think you =
have already done
> | > some work on this in the code using CCID2_WIN_CHANGE_FACTOR.
> |=20
> | I'm not entirely certain what low_threshold and high_threshold you ar=
e
> | talking about. I have not seen sequence window oscillations other as =
the
> | congestion window oscillates in congestion avoidance as is expected.
> |
> I meant a Schmitt Trigger like behaviour:
>  * low_threshold: to change from lower value to higher value=20
>  * hi_threshold:  to revert from higher value back to lower value
> In these electronic devices there is a gap between low and hi, to avoid=
 fluctuations.
> Also audio effect gates have a similar setting.

That makes sense now. Thanks for the explanation. I didn't write the
current code with that in mind. However, it does a good job at avoiding
oscillation most of the time.


Below is the very last patch you added to the test tree. I believe both
of the changes made are not needed. See comments inline.
> dccp ccid-2: replace remaining references to local Sequence Window valu=
e
>=20
> This replaces the remaining references to dccps_l_seq_win with the corr=
esponding
> call to retrieve the current (STABLE if not in negotiation, CHANGING if=
 being
> negotiated) value of the feature-local sequence window.
>=20
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/ccids/ccid2.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>=20
> --- a/net/dccp/ccids/ccid2.c
> +++ b/net/dccp/ccids/ccid2.c
> @@ -441,10 +441,10 @@ static void ccid2_new_ack(struct sock *s
>  {
>  	struct ccid2_hc_tx_sock *hc =3D ccid2_hc_tx_sk(sk);
>  	struct dccp_sock *dp =3D dccp_sk(sk);
> +	u64 l_seq_win =3D dccp_feat_nn_get(sk, DCCPF_SEQUENCE_WINDOW);
>  	int r_seq_used =3D hc->tx_cwnd / dp->dccps_l_ack_ratio;
> =20
> -	if (hc->tx_cwnd < dp->dccps_l_seq_win &&
> -	    r_seq_used < dp->dccps_r_seq_win) {
> +	if (hc->tx_cwnd < l_seq_win && r_seq_used < dp->dccps_r_seq_win) {
>  		if (hc->tx_cwnd < hc->tx_ssthresh) {
>  			if (*maxincr > 0 && ++hc->tx_packets_acked >=3D 2) {
>  				hc->tx_cwnd +=3D 1;

In this case I believe we want to wait and use the confirmed sequence
window size (like the unmodified code does).

Using the currently negotiating value could result in a congestion
window much larger than the current sequence window (particularly if the
change below is used). This could cause the validity checking code
(dccp_check_seqno) to reject received packets (prior to the confirm) as
sequence invalid. Further, we essentially move back to changing the
effective sequence window before sending the confirm.


> @@ -466,10 +466,10 @@ static void ccid2_new_ack(struct sock *s
>  	else if (r_seq_used * CCID2_WIN_CHANGE_FACTOR < dp->dccps_r_seq_win/2=
)
>  		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio / 2 ? : 1U);
> =20
> -	if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR >=3D dp->dccps_l_seq_win)
> -		ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win * 2);
> -	else if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR < dp->dccps_l_seq_win/=
2)
> -		ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win / 2);
> +	if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR >=3D l_seq_win)
> +		ccid2_change_l_seq_window(sk, l_seq_win * 2);
> +	else if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR < l_seq_win / 2)
> +		ccid2_change_l_seq_window(sk, l_seq_win / 2);
> =20
>  	/*
>  	 * FIXME: RTT is sampled several times per acknowledgment (for each

Here again, I believe we want to wait and use the confirmed sequence
window size (like the unmodified code does).

Using the currently negotiating value could result in never increasing
the actual sequence window---We ignore confirms for old values so if
begin negotiating a new value before we confirm the previous value we
run the risk of attempting to negotiate a new value several times an
RTT, which results in always receiving (and ignoring) old values.


Samuel Jero
Internetworking Research Group
Ohio University


--------------enigEE9D2D32C7F44E6361E34BBD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2IAA8ACgkQEwoGUlJjrt8uKQCfQxNrJPjoxqUOllSAGp1SoIgJ
SmEAn1e41L02yciH+/fp94/nm9iN41S3
=Ul7/
-----END PGP SIGNATURE-----

--------------enigEE9D2D32C7F44E6361E34BBD--
