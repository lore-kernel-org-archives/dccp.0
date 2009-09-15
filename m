From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 15 Sep 2009 00:40:40 +0000
Subject: Re: [PATCH 4/5] Adds options DROPPED PACKETS and LOSS INTERVALS to
Message-Id: <cb00fa210909141740u585116c7i45165054d741a022@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011945u2d82da97i7a7f2d1f12519a5f@mail.gmail.com>
In-Reply-To: <cb00fa210909011945u2d82da97i7a7f2d1f12519a5f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

The comments follow below


On Sun, Sep 13, 2009 at 15:41, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> | Adds options DROPPED PACKETS and LOSS INTERVALS to receiver. In this pa=
tch is added the
> | mechanism of gathering information about loss intervals and storing it,=
 for later
> | construction of these two options.
> This also needs some more work, please see inline.
>

<snip>

>
> + =A0 =A0 =A0 tfrc_sp_update_li_data(ld, h, skb, new_loss, new_event);
> +
> I don't understand why 'tfrc_sp_update_li_data' is called twice, one call=
 seems
> to be redundant. What it seems to be wanting to do is

When we are designing the loss count algorithm it seemed to be
necessary, but now that i need to revise this (patch n=BA 2),  I'll
observe this.


> =A0 =A0 =A0 =A0bool new_loss =3D false;
>
> =A0 =A0 =A0 =A0//...
<snip>
> at the begin of the function, all subsequent 'dccp_data_packet(skb)' are =
unnecessary.
> Almost every 'if' statement ends in 'return', this seems ad-hoc and could=
 be reduced
> by adding if-else-if-else-if..., which would probably also reduce the cod=
e duplication.
>

I'll try to reduce code duplication, thanks.

>
> @@ -244,8 +463,11 @@
> =A0 =A0 =A0 =A0tfrc_lh_slab =3D kmem_cache_create("tfrc_sp_li_hist",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 sizeof(struct tfrc_loss_interval), 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 SLAB_HWCACHE_ALIGN, NULL);
> + =A0 =A0 =A0 tfrc_ld_slab =3D kmem_cache_create("tfrc_sp_li_data",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0sizeof(struct tfrc_loss_data_entry), 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0SLAB_HWCACHE_ALIGN, NULL);
>
> - =A0 =A0 =A0 if ((tfrc_lh_slab !=3D NULL))
> + =A0 =A0 =A0 if ((tfrc_lh_slab !=3D NULL) || (tfrc_ld_slab !=3D NULL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> =A0 =A0 =A0 =A0if (tfrc_lh_slab !=3D NULL) {
> @@ -253,6 +475,11 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_lh_slab =3D NULL;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if (tfrc_ld_slab !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_destroy(tfrc_ld_slab);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_ld_slab =3D NULL;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0return -ENOBUFS;
> =A0}
> The condition above should be '&&', not '||'. Suggested alternative:
>
> + =A0 =A0 =A0 if (tfrc_lh_slab =3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto lh_failed;
> +
> + =A0 =A0 =A0 tfrc_ld_slab =3D kmem_cache_create("tfrc_sp_li_data",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0sizeof(struct tfrc_loss_data_entry), 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0SLAB_HWCACHE_ALIGN, NULL);
> + =A0 =A0 =A0 if (tfrc_ld_slab !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 kmem_cache_destroy(tfrc_lh_slab);
> + =A0 =A0 =A0 tfrc_lh_slab =3D NULL;
> +lh_failed:
> + =A0 =A0 =A0 return -ENOBUFS;
> =A0}
>

Thanks for revising this. Adding one label for each failure case will
not scale well. In another patch it will be needed to create another
structure, and so, requiring another label.



>
>
>
> --- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.h
> +++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h
> @@ -70,13 +70,52 @@
> =A0struct tfrc_rx_hist;
> =A0#endif
>
> +struct tfrc_loss_data_entry {
> + =A0 =A0 =A0 struct tfrc_loss_data_entry =A0 =A0 *next;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 lossless_length:24;
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0ecn_nonce_sum:1;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 loss_length:24;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 data_length:24;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 drop_count:24;
> +};
> According to RFC 4342, 8.6.1, Loss Length is a 23-bit number, i.e.
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 loss_length:23;
>

Thanks!

>
>
>
> +#define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH =A0 =A0 28
> +#define TFRC_DROP_OPT_MAX_LENGTH =A0 =A0 =A0 =A0 =A0 =A0 =A0 84
> +#define TFRC_LI_OPT_SZ \
> + =A0 =A0 =A0 (2 + TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH*9)
> +#define TFRC_DROPPED_OPT_SZ \
> + =A0 =A0 =A0 (1 + TFRC_DROP_OPT_MAX_LENGTH*3)
> It would be good to have a reminder where the numbers come from, i.e.
> =A0* the "28" comes from RFC 4342, 8.6
> =A0* the "84" comes from RFC 5622, 8.7
> =A0* the "9" again is from RFC 4342, 8.6
> =A0* the 1 + TFRC_DROP_OPT_MAX_LENGTH*3 =3D DCCP_SINGLE_OPT_MAXLEN (linux=
/dccp.h)
>
Sorry, this documentation was written, but i left it in another future patc=
h.

>
> +struct tfrc_loss_data {
> + =A0 =A0 =A0 struct tfrc_loss_data_entry =A0 =A0 *head;
> + =A0 =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 counter;
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0loss_intervals_opts[TFRC_LI_OPT_SZ];
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0drop_opts[TFRC_DROPPED_OPT_SZ];
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0last_loss_count;
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0sto_ecn;
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0sto_is_data;
> +};
>
>
>
> +static inline void tfrc_ld_init(struct tfrc_loss_data *ld)
> +{
> + =A0 =A0 =A0 memset(ld, 0, sizeof(struct tfrc_loss_data));
> +}
> A tip from CodingStyle - using "sizeof(*ld)" will continue to work if the=
re
> are changes in the interface.
>

Thanks.


>
> --- dccp_tree_work5.orig/net/dccp/dccp.h
> +++ dccp_tree_work5/net/dccp/dccp.h
> @@ -403,6 +403,16 @@
> =A0 =A0 =A0 =A0return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) =3D I=
NET_ECN_CE;
> =A0}
>
> +static inline bool dccp_skb_is_ecn_ect0(const struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) =3D IN=
ET_ECN_ECT_0;
> +}
> +
> +static inline bool dccp_skb_is_ecn_ect1(const struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) =3D IN=
ET_ECN_ECT_0;
> +}
> The routines are not needed, because the dccpd_ecn field is (deliberately=
) only
> 2 bits wide. In the second case it should have been INET_ECN_ECT_1.
>

And how would be to determine if one packet's ecn is set to ECT 0 or ECT 1?


--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
