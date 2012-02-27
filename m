From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Mon, 27 Feb 2012 08:52:02 +0000
Subject: Re: [PATCH 1/1] dccp ccid-3: replace incorrect BUG_ON
Message-Id: <CAG_Kctom-Jv+mnbyOoYhcubP59U2aArmxHuakK3pzQEX7VBDuw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20120227020554.GB14246@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20120227020554.GB14246@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.uk>

On 27 February 2012 02:05, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> dccp ccid-3: replace incorrect BUG_ON
>
> This replaces an unjustified BUG_ON(), which could get triggered under no=
rmal
> conditions: X_calc can be 0 when p > 0. X would in this case be set to the
> minimum, s/t_mbi. Its replacement avoids t_ipi =3D 0 (unbounded sending r=
ate).
>
> Thanks to Jordi, Victor and Xavier who reported this.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
> =A0net/dccp/ccids/ccid3.c | =A0 =A03 +--
> =A01 file changed, 1 insertion(+), 2 deletions(-)
>
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -98,6 +98,7 @@ static void ccid3_update_send_interval(s
> =A0{
> =A0 =A0 =A0 =A0hc->tx_t_ipi =3D scaled_div32(((u64)hc->tx_s) << 6, hc->tx=
_x);
>
> + =A0 =A0 =A0 DCCP_BUG_ON(hc->tx_t_ipi =3D 0);
> =A0 =A0 =A0 =A0ccid3_pr_debug("t_ipi=3D%u, s=3D%u, X=3D%u\n", hc->tx_t_ip=
i,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hc->tx_s, (unsigned)(hc->tx_x=
 >> 6));
> =A0}
> @@ -236,8 +237,6 @@ static void ccid3_hc_tx_no_feedback_time
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * =A0Note that X_recv is scaled by 2^6 wh=
ile X_calc is not
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(hc->tx_p && !hc->tx_x_calc);
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hc->tx_x_recv > =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max(hc->tx_x_recv / =
2,
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
