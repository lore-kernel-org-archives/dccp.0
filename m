From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Tue, 21 Feb 2012 17:43:26 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <CAG_Kcto25XktBEU0Nokipu9vCGkfhh5WSi-HhhYC1w8DVnHNDQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Would suggest that patch is worth pushing upstreams then as quickly as we c=
an...

On 21 February 2012 15:05, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> Here is a patch that can be used in place of enabling the debug messages.
> It may be easier to use this, especially if it takes long to reproduce the
> bug.
>
> From a quick look it seems that x_calc =3D 0 will do no harm in the old
> code, since
> ccid3_hc_tx_update_x() is called subsequently, it will set x to s/t_mbi
>
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -237,7 +237,11 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned
> long data)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * =A0Note that X_recv is scaled by 2^6 wh=
ile X_calc is not
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(hc->tx_p && !hc->tx_x_calc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (hc->tx_p && !hc->tx_x_calc)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DCCP_CRIT("ERROR: s=3D%u, p=
=3D%u, x_calc =3D %u, x_recv
> =3D %llu, X =3D %llu",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hc->tx_s, h=
c->tx_p, hc->tx_x_calc,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned l=
ong long)hc->tx_x_recv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned l=
ong long)hc->tx_x);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hc->tx_x_recv > --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
