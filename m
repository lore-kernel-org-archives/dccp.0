From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Feb 2012 02:05:01 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <20120227020500.GA14246@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Ian,
| Would suggest that patch is worth pushing upstreams then as quickly as we=
 can...
|=20
I went through the code again and found that X_calc =3D 0 does not cause ha=
rm, due
to clamping to s/t_mbi. My suggestion is to remove this BUG_ON and to test =
instead
if t_ipi =3D 0 (since this would allow flooding of network).

Patch is in the next email, test tree has been updated, also CCID-4 has now
the same change (removed X_calc BUG_ON, added t_ipi=3D0 BUG_ON).

Gerrit

| On 21 February 2012 15:05, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
| >
| > Here is a patch that can be used in place of enabling the debug message=
s.
| > It may be easier to use this, especially if it takes long to reproduce =
the
| > bug.
| >
| > From a quick look it seems that x_calc =3D 0 will do no harm in the old
| > code, since
| > ccid3_hc_tx_update_x() is called subsequently, it will set x to s/t_mbi
| >
| > --- a/net/dccp/ccids/ccid3.c
| > +++ b/net/dccp/ccids/ccid3.c
| > @@ -237,7 +237,11 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned
| > long data)
| > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *
| > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * =A0Note that X_recv is scaled by 2^6 =
while X_calc is not
| > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
| > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(hc->tx_p && !hc->tx_x_calc);
| > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (hc->tx_p && !hc->tx_x_calc)
| > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DCCP_CRIT("ERROR: s=3D%u,=
 p=3D%u, x_calc =3D %u, x_recv
| > =3D %llu, X =3D %llu",
| > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hc->tx_s,=
 hc->tx_p, hc->tx_x_calc,
| > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned=
 long long)hc->tx_x_recv,
| > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned=
 long long)hc->tx_x);
| >
| > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
| > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hc->tx_x_recv | > --
| > To unsubscribe from this list: send the line "unsubscribe dccp" in
| > the body of a message to majordomo@vger.kernel.org
| > More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
| --
| To unsubscribe from this list: send the line "unsubscribe dccp" in
| the body of a message to majordomo@vger.kernel.org
| More majordomo info at  http://vger.kernel.org/majordomo-info.html
|=20

--=20
