From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 15 Sep 2009 00:39:02 +0000
Subject: Re: [PATCH 2/5] Implement loss counting on TFRC-SP receiver
Message-Id: <cb00fa210909141739y234302b3x9c6df23b057a9473@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
In-Reply-To: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

In the same way, my comments follow below


> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s64 len =3D dccp_delta_seqno(cur->li_seqno=
, cong_evt_seqno);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((len <=3D 0) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(!tfrc_lh_closed_check(cur, cong_e=
vt->tfrchrx_ccval))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur->li_losses +=3D rh->num=
_losses;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> This has a multiplicative effect, since rh->num_losses is added to cur->l=
i_losses
> each time the condition is evaluated. E.g. if 3 times in a row reordered =
(earlier)
> sequence numbers arrive, or if the CCvals do not differ (high-speed netwo=
rks),
> we end up with 3 * rh->num_losses, which can't be correct.
>
>


The following code would be correct then?

              if ((len <=3D 0) ||
                  (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval))) {
+                       cur->li_losses +=3D rh->num_losses;
+                       rh->num_losses  =3D 0;
                      return false;
With this change I suppose the could be fixed. With that, the
rh->num_losses couldn't added twice. Am I correct?




>
> --- dccp_tree_work4.orig/net/dccp/ccids/lib/packet_history_sp.c
> +++ dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.c
> @@ -244,6 +244,7 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0h->loss_count =3D 3;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_his=
t_entry(h, 3),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 skb, n3);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->num_losses =3D dccp_loss_count(s2, s3, n=
3);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0}
> This only measures the gap between s2 and s3, but the "hole" starts at s0,
> so it would need to be dccp_loss_count(s0, s3, n3). Algorithm is document=
ed at
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/\
> ccid3/ccid3_packet_reception/loss_detection/loss_detection_algorithm_note=
s.txt
>

<snip>

> =A0}
> Here it is also between s0 and s2, not between s0 and s3. It is case VI(c=
.3).
>
> However, the above still is a crude approximation, since it only measures=
 between
> the last sequence number received before the loss and the third sequence =
number
> after the loss. It would be better to either
>
> =A0* use the first sequence number after the loss (this can be s1, s2, or=
 s3) or
> =A0* check if there are more holes between the first/second and the secon=
d/third
> =A0 sequence numbers after the loss.
>
> The second option would be the correct one, it should also take the NDP c=
ounts
> of each gap into account. And already we have a fairly complicated algori=
thm.
>



I'll study loss_detection_algorithm_notes.txt and correct the code.
But I have one question, that i don't know if is already answered by
the documentation:
Further holes, between the the first and third packet received after
the hole are accounted only in future calls to the function, right?
Because the receiver needs to receive more packets to confirm loss,
right?
So, it's really necessary to look for other holes after the loss? Will
not this other holes be identified as losses in future?



> Another observation is that this function is only called in packet_histor=
y_sp.c,
> and only in __two_after_loss(), so that dccp_loss_count() could be made s=
tatic,
> and without the need for the WARN_ON (see below), since in all above case=
s it is
> ensured that the first sequence number argument is "before" the second on=
e.
>

Okay.
>
> --- dccp_tree_work4.orig/net/dccp/ccids/lib/packet_history_sp.h
> +++ dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.h
> @@ -113,6 +113,7 @@
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 packet_siz=
e,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bytes_=
recvd;
> =A0 =A0 =A0 =A0ktime_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bytes_start;
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0num_losse=
s;
> =A0};
> No more than 255 losses? NDP count option has space for up to 6 bytes, i.=
e. 2^48-1.
> Suggest u64 for consistency with the other parts.
>

Okay.


>
> --- dccp_tree_work4.orig/net/dccp/dccp.h
> +++ dccp_tree_work4/net/dccp/dccp.h
> @@ -168,6 +168,21 @@
> =A0 =A0 =A0 =A0return (u64)delta <=3D ndp + 1;

<snip>

> But then dccp_loss_free reduces to a specialisation of the above:
> bool dccp_loss_free(const u64 s1, const u64 s2, const u64 ndp)
> {
> =A0 =A0 =A0 =A0return dccp_loss_count(s1, s2, ndp) =3D 0;
> }
>
> But please see above -- the function needs to be called for each hole in =
a row.
>

Thanks for correcting the calculation for me!

--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
