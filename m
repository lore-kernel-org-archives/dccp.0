From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 21 Oct 2009 13:20:12 +0000
Subject: Re: [PATCH 3/4] Implement dropped packets option
Message-Id: <cb00fa210910210620q4754dbfbgb0e90a88b20ef7fc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B80D.8090207@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B80D.8090207@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, Oct 19, 2009 at 2:24 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrot=
e:
>
> | +static struct tfrc_tx_hist_entry*
> | + =A0 =A0 tfrc_sp_seek_tx_entry(struct tfrc_tx_hist_entry *head,
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 seqno, u32 ba=
ckward)
> | +{
> | + =A0 =A0 if (head =3D NULL)
> | + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> | +
> | + =A0 =A0 while (head->seqno !=3D seqno) {
> | + =A0 =A0 =A0 =A0 =A0 =A0 head =3D head->next;
> | +
> | + =A0 =A0 =A0 =A0 =A0 =A0 if (head =3D NULL)
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> | + =A0 =A0 }
> | +
> | + =A0 =A0 while (backward-- > 0) {
> | + =A0 =A0 =A0 =A0 =A0 =A0 head =3D head->next;
> | +
> | + =A0 =A0 =A0 =A0 =A0 =A0 if (head =3D NULL)
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> | + =A0 =A0 }
> | +
> | + =A0 =A0 return head;
> | +}
> | +
> | +/*
> | + * tfrc_sp_p_from_loss_intervals_opt =A0- =A0calcs p from loss interva=
l option
> | + * li_data: =A0 =A0 =A0 =A0 =A0data parsed from options
> | + * head: =A0 =A0 =A0 =A0 =A0 =A0 contains ccval info
> | + * curr_ccval: =A0 =A0 =A0 =A0 =A0 =A0 =A0 current ccval
> | + * seqno: =A0 =A0 =A0 =A0 =A0 =A0last acked seqno
> | + */
> | +u32 tfrc_sp_p_from_loss_intervals_opt(struct tfrc_tx_li_data *li_data,
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s=
truct tfrc_tx_hist_entry *head,
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u=
8 curr_ccval, u64 seqno)
> | +{
> <snip>
> | +
> | + =A0 =A0 for (i =3D 1; i <=3D k; i++) {
> | + =A0 =A0 =A0 =A0 =A0 =A0 i_i =3D li_data->loss_interval_data[i];
> | + =A0 =A0 =A0 =A0 =A0 =A0 i_totl +=3D i_i;
> | + =A0 =A0 =A0 =A0 =A0 =A0 ccval =3D tfrc_sp_seek_tx_entry(head, seqno, =
i_totl - 1)->ccval;
>
> tfrc_sp_seek_tx_entry() can return NULL (as per above implementation). Th=
en this
> will crash/panic.
>

Thanks for observing this.

> <snip>
> | +
> | + =A0 =A0 =A0 =A0 =A0 =A0 if (i > 1)
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i_tot1 +=3D i_i * tfrc_lh_wei=
ghts[i-2];
> | + =A0 =A0 }
> | +
> | + =A0 =A0 ccval =3D tfrc_sp_seek_tx_entry(head, seqno,
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li_data->loss_interval_data[1=
] - 1)->ccval;
> Here it can also crash.

Thanks, will be fixed.

>
> Getting a sender-based implementation right is complex, since it requires=
 to
> enforce consistency and garbage collection for so many data structures.
>

Yes, it can take time.

> That is why I think it would be easier to start with a receiver-based imp=
lementation
> and then grow it into a sender-based implementation if it shows promise.

Agreed.

--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
