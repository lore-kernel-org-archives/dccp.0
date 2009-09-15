From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 15 Sep 2009 00:38:07 +0000
Subject: Re: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <cb00fa210909141738l60d02cd5p287d990326ce6c3c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
In-Reply-To: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Gerrit and all.
Thank you for your fast reply. My comments follow below

On Sat, Sep 12, 2009 at 15:32, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hi Ivo,
>
> you have made a really good job of sticking to code conventions (see other
> posting). There are a few things that needed tending to in the first patc=
h.
>
> (1) Version changes
> =3D=3D=3D=3D=3D=3D=3D=3D=3D> It seems that you applied something like s/\=
*\*/*/g to the first instance of
> the patch, in order to remove duplicate asterisks. This caused a problem:
>
> --- tfrc_sp_receiver_01.patch =A0 2009/09/12 08:37:12 =A0 =A0 1.1
> +++ tfrc_sp_receiver_01.patch =A0 2009/09/08 17:34:40
> @@ -1001,8 +1001,8 @@ Index: dccp_tree_work4/net/dccp/ccids/li
> =A0+
> =A0+#endif
> =A0+
> -+extern int =A0tfrc_sp_tx_hist_add(struct tfrc_tx_hist_entry **headp, u6=
4 seqno);
> -+extern void tfrc_sp_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
> ++extern int =A0tfrc_sp_tx_hist_add(struct tfrc_tx_hist_entry *headp, u64=
 seqno);
> ++extern void tfrc_sp_tx_hist_purge(struct tfrc_tx_hist_entry *headp);
>
> I have reverted the bug, also to minimise the difference to the existing =
(non
> TFRC-SP) files.
>
>
> (2) Other changes that I edited out
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> (Other than whitespa=
ce changes.)
>
> net/dccp/ccids/lib/loss_interval_sp.c
> -------------------------------------
> I replaced the following dead code
> =A0 =A0 =A0 =A0if ((tfrc_lh_slab !=3D NULL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> =A0 =A0 =A0 =A0if (tfrc_lh_slab !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kmem_cache_destroy(tfrc_lh_slab);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_lh_slab =3D NULL;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return -ENOBUFS;
> with
> =A0 =A0 =A0 =A0return tfrc_lh_slab =3D NULL ? -ENOBUFS : 0;
>
> Also separated the conditions
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((len <=3D 0) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (!tfrc_lh_closed_check(cur, cong_ev=
t->tfrchrx_ccval))) {
> back into
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (len <=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!tfrc_lh_closed_check(cur, cong_evt->t=
frchrx_ccval))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>

Thanks!




> I removed the following unnecessary inclusion:
> +#include <linux/random.h>
>

I should not have included that header now, it'll be only necessary in
another patch



>
> The following function pokes a hole in thei so far "abstract" data type;
> the convention has been to access the internals of the struct only via
> get-functions:
>
> static inline struct tfrc_loss_interval
> =A0 =A0 =A0 =A0*tfrc_lh_get_loss_interval(struct tfrc_loss_hist *lh, cons=
t u8 i)
> {
> =A0 =A0 =A0 =A0BUG_ON(i >=3D lh->counter);
> =A0 =A0 =A0 =A0return lh->ring[LIH_INDEX(lh->counter - i - 1)];
> }
>
> (You use it in patch 3/5 to gain access to li_ccval and li_losses.
> Better would be to have two separate accessor functions.)
>

Okay, I will fix this.




>
> net/dccp/ccids/lib/tfrc_equation_sp.c
> -------------------------------------
> This is a prime candidate for removal. After editing out the whitespace
> differences, I found that it is 100% identical with tfrc_equation.c.
>
> The result of this editing has been uploaded to
> http://eden-feed.erg.abdn.ac.uk/tfrc_sp_receiver_01.patch
>
One future patch will need to modify this file, but now it's really an
exact copy.


--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
