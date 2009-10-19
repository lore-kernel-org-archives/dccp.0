From: Leandro Sales <leandroal@gmail.com>
Date: Mon, 19 Oct 2009 16:04:15 +0000
Subject: Re: [PATCHv2 2/4] Implement loss counting on TFRC-SP receiver
Message-Id: <5bc4c4570910190904t1ee39a02i8df1354ca8929a2a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B67F.8040208@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B67F.8040208@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Gerrit,

On Mon, Oct 19, 2009 at 2:26 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrot=
e:
>
> | --- dccp_tree_work03.orig/net/dccp/ccids/lib/packet_history_sp.c =A0 =
=A0 =A02009-10-08 22:58:21.418908270 -0300
> | +++ dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.c =A0 2009-10=
-08 22:59:07.442411383 -0300
> | @@ -243,6 +243,7 @@
> | =A0{
> | =A0 =A0 =A0 u64 s0 =3D tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
> | =A0 =A0 =A0 =A0 =A0 s1 =3D tfrc_rx_hist_entry(h, 1)->tfrchrx_seqno,
> | + =A0 =A0 =A0 =A0 n1 =3D tfrc_rx_hist_entry(h, 1)->tfrchrx_ndp,
> | =A0 =A0 =A0 =A0 =A0 s2 =3D tfrc_rx_hist_entry(h, 2)->tfrchrx_seqno,
> | =A0 =A0 =A0 =A0 =A0 s3 =3D DCCP_SKB_CB(skb)->dccpd_seq;
> I have removed the old definition of n1, which was further below and whic=
h caused this warning.
>
> net/dccp/ccids/lib/packet_history_sp.c:276:7: warning: symbol 'n1' shadow=
s an earlier
> net/dccp/ccids/lib/packet_history_sp.c:247:6: originally declared here
>
>

Well done!

> I thought again about the earlier suggestion to make 'num_losses' u64. Si=
nce li_losses sums the values
> stored in num_losses, it needs to have the same size (currently it is u32=
). But then another thought is
> that if there are so many losses that u32 overflows, then the performance=
 is so bad anyway that it is
> better to turn off the receiver. Hence I have reverted it to u32, as per =
your original patch.
>

OK

> Please find attached a patch of the changes I made. As per posting, I hav=
e separated out the dccp.h part,
> since it is also useful in general.

OK, agreed!

Thank you,

BR,
Leandro.
