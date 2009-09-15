From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 15 Sep 2009 00:39:46 +0000
Subject: Re: [PATCH 3/5] Implement TFRC-SP calc of mean length of loss
Message-Id: <cb00fa210909141739t6046a402w4aa04680f31dbec@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011945l1c44d1eap90329a4c6eb0480a@mail.gmail.com>
In-Reply-To: <cb00fa210909011945l1c44d1eap90329a4c6eb0480a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

The comments follow below



On Sun, Sep 13, 2009 at 14:28, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> | Implement TFRC-SP calc of mean length of loss intervals accordingly to
> | section 3 of RFC 4828
> Sorry this also has problems.
>
> --- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.c
> +++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.c
> @@ -67,10 +67,11 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0}
>
> -static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh)
> +static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh, __u8 curr_=
ccval)
> =A0{
> =A0 =A0 =A0 =A0u32 i_i, i_tot0 =3D 0, i_tot1 =3D 0, w_tot =3D 0;
> =A0 =A0 =A0 =A0int i, k =3D tfrc_lh_length(lh) - 1; /* k is as in rfc3448=
bis, 5.4 */
> + =A0 =A0 =A0 u32 losses;
>
> =A0 =A0 =A0 =A0if (k <=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> @@ -78,6 +79,15 @@
> =A0 =A0 =A0 =A0for (i =3D 0; i <=3D k; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i_i =3D tfrc_lh_get_interval(lh, i);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (SUB16(curr_ccval,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_lh_get_loss_interval(lh, i)->l=
i_ccval) <=3D 8) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 losses =3D tfrc_lh_get_loss=
_interval(lh, i)->li_losses;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (losses > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i_i =3D div=
64_u64(i_i, losses);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> (Both 'i_i' and 'losses' are u32, so could write "i_i /=3D losses" instea=
d.)
>
> However, this computation is done in the wrong place: here it is already =
too
> late. The N/K in RFC 4828 refers to entering each individual interval I_0=
, so
> the division (and the check whether this is a "short" interval) needs to =
be
> done when adding the interval, in tfrc_sp_lh_interval_add(). (There also =
exists
> a special rule for the open interval I_0, see RFC 5348, 5.3.)
>


Oh, all right. I understood it was wrong. I thought that the loss
interval needed to be less than 2 rtt old
but the correct is that it needs to be less than 2 rtt long, right?


> A second problem is a divide-by-zero condition encoded in the above: if
> i_i < losses, the result is 0, if all intervals are 0 then I_mean =3D 0, =
and
> thus p =3D 1/I_mean triggers a panic. In all other cases, the integer ari=
thmetic
> has the effect of floor(N/K), i.e. it decreases the interval length.
>
> A way out (which does not fix the truncation problem) is to round up:
>
> =A0 =A0 =A0 =A0if (losses > 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i_i =3D DIV_ROUND_UP(i_i, losses);
>
> In fact, we have to do this, to avoid the divide-by-zero condition.


When the loss count (losses) could be greater than loss interval length (i_=
i)?



>
> The third problem is that the CCVal can be wrong, i.e. "less than 8" can
> also mean that it just wrapped around one or more times. But this is noted
> already in RFC 5622, it is a problem of the specification.
>
> @@ -87,6 +97,11 @@
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0lh->i_mean =3D max(i_tot0, i_tot1) / w_tot;
> + =A0 =A0 =A0 BUG_ON(w_tot =3D 0);
> + =A0 =A0 =A0 if (SUB16(curr_ccval, tfrc_lh_get_loss_interval(lh, 0)->li_=
ccval) > 8)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lh->i_mean =3D max(i_tot0, i_tot1) / w_tot;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lh->i_mean =3D i_tot1 / w_tot;
> =A0}
> The line above the BUG_ON is probably a leftover. For the BUG_ON, this wo=
uld
> be too late (division by zero).
> In fact, the BUG_ON is not needed, due to testing for k <=3D 0, see
> http://mirror.celinuxforum.org/gitstat//commit-detail.php?commit=EFf253c4=
272cd2aac95ccff46d3d2e1a495f22b1
>
> @@ -127,7 +142,7 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0cur->li_length =3D len;
> - =A0 =A0 =A0 tfrc_sp_lh_calc_i_mean(lh);
> + =A0 =A0 =A0 tfrc_sp_lh_calc_i_mean(lh, dccp_hdr(skb)->dccph_ccval);
> =A0}
> Should be division as per above.
>
> --- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.h
> +++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h
> @@ -73,7 +73,8 @@
> =A0extern bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0st=
ruct tfrc_rx_hist *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u3=
2 (*first_li)(struct sock *),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct sock *);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct sock *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __u=
8 ccval);
> This function already has the ccval available, so could use it instead
> of just passing it through.
>

Thanks for observing these points!

--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
