From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 02 Sep 2009 02:45:28 +0000
Subject: [PATCH 3/5] Implement TFRC-SP calc of mean length of loss intervals
Message-Id: <cb00fa210909011945l1c44d1eap90329a4c6eb0480a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Implement TFRC-SP calc of mean length of loss intervals accordingly to
section 3 of RFC 4828

Changes:
=A0- Modify tfrc_sp_lh_calc_i_mean header, now receiving the current
ccval, so it can determine
=A0 if a loss interval is too recent
=A0- Consider number of losses in each loss interval
=A0- Only consider open loss interval if it is at least 2 rtt old
=A0- Changes function signatures as necessary

Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales
<ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>,
<leandroal@gmail.com>

Index: b/net/dccp/ccids/lib/loss_interval_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/loss_interval_sp.c =A0 =A0=
 2009-08-26
23:28:27.000000000 -0300
+++ b/net/dccp/ccids/lib/loss_interval_sp.c =A0 =A0 2009-08-26
23:53:32.000000000 -0300
@@ -66,10 +66,11 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
=A0}

-static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh)
+static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh, __u8 curr_cc=
val)
=A0{
=A0 =A0 =A0 =A0u32 i_i, i_tot0 =3D 0, i_tot1 =3D 0, w_tot =3D 0;
=A0 =A0 =A0 =A0int i, k =3D tfrc_lh_length(lh) - 1; /* k is as in rfc3448bi=
s, 5.4 */
+ =A0 =A0 =A0 u32 losses;

=A0 =A0 =A0 =A0if (k <=3D 0)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
@@ -77,6 +78,14 @@
=A0 =A0 =A0 =A0for (i =3D 0; i <=3D k; i++) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i_i =3D tfrc_lh_get_interval(lh, i);

+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (SUB16(curr_ccval,
tfrc_lh_get_loss_interval(lh,i)->li_ccval) <=3D 8)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 losses =3D tfrc_lh_get_loss_i=
nterval(lh,i)->li_losses;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (losses > 0)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i_i =3D div64=
_u64(i_i, losses);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (i < k) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i_tot0 +=3D i_i * tfrc_lh_we=
ights[i];
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0w_tot =A0+=3D tfrc_lh_weight=
s[i];
@@ -86,6 +95,12 @@
=A0 =A0 =A0 =A0}

=A0 =A0 =A0 =A0lh->i_mean =3D max(i_tot0, i_tot1) / w_tot;
+ =A0 =A0 =A0 BUG_ON(w_tot =3D 0);
+ =A0 =A0 =A0 if (SUB16(curr_ccval, tfrc_lh_get_loss_interval(lh,0)->li_ccv=
al) > 8) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 lh->i_mean =3D max(i_tot0, i_tot1) / w_tot;
+ =A0 =A0 =A0 } else {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 lh->i_mean =3D i_tot1 / w_tot;
+ =A0 =A0 =A0 }
=A0}

=A0/**
@@ -126,7 +141,7 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;

=A0 =A0 =A0 =A0cur->li_length =3D len;
- =A0 =A0 =A0 tfrc_sp_lh_calc_i_mean(lh);
+ =A0 =A0 =A0 tfrc_sp_lh_calc_i_mean(lh, dccp_hdr(skb)->dccph_ccval);
=A0}

=A0/* RFC 4342, 10.2: test for the existence of packet with sequence number=
 S */
@@ -145,7 +160,7 @@
=A0* Updates I_mean and returns 1 if a new interval has in fact been
added to @lh.
=A0*/
=A0bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *lh, struct
tfrc_rx_hist *rh,
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 (*calc_first_l=
i)(struct sock *),
struct sock *sk)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 (*calc_first_l=
i)(struct sock *),
struct sock *sk, __u8 ccval)
=A0{
=A0 =A0 =A0 =A0struct tfrc_loss_interval *cur =3D tfrc_lh_peek(lh);
=A0 =A0 =A0 =A0struct tfrc_rx_hist_entry *cong_evt;
@@ -214,7 +229,7 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (lh->counter > (2*LIH_SIZE))
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lh->counter -=3D LIH_SIZE;

- =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_sp_lh_calc_i_mean(lh);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_sp_lh_calc_i_mean(lh, ccval);
=A0 =A0 =A0 =A0}

=A0 =A0 =A0 =A0return true;
Index: b/net/dccp/ccids/lib/loss_interval_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/loss_interval_sp.h =A0 =A0=
 2009-08-26
22:52:20.000000000 -0300
+++ b/net/dccp/ccids/lib/loss_interval_sp.h =A0 =A0 2009-08-26
23:44:20.000000000 -0300
@@ -71,7 +71,7 @@
=A0#endif

=A0extern bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *, struct
tfrc_rx_hist *,
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 (=
*first_li)(struct sock *),
struct sock *);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 (=
*first_li)(struct sock *),
struct sock *, __u8 ccval);
=A0extern void tfrc_sp_lh_update_i_mean(struct tfrc_loss_hist *lh,
struct sk_buff *);
=A0extern void tfrc_sp_lh_cleanup(struct tfrc_loss_hist *lh);

Index: b/net/dccp/ccids/lib/packet_history_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/packet_history_sp.c =A0 =
=A02009-08-26
22:55:01.000000000 -0300
+++ b/net/dccp/ccids/lib/packet_history_sp.c =A0 =A02009-08-26
23:49:59.000000000 -0300
@@ -359,7 +359,7 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Update Loss Interval database and recycle =
RX records
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_event =3D tfrc_sp_lh_interval_add(lh, h, =
first_li, sk);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_event =3D tfrc_sp_lh_interval_add(lh, h, =
first_li, sk,
dccp_hdr(skb)->dccph_ccval);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__three_after_loss(h);

=A0 =A0 =A0 =A0} else if (dccp_data_packet(skb) && dccp_skb_is_ecn_ce(skb))=
 {
@@ -368,7 +368,7 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the RFC considers ECN marks - a future imp=
lementation may
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* find it useful to also check ECN marks on =
non-data packets.
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_event =3D tfrc_sp_lh_interval_add(lh, h, =
first_li, sk);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_event =3D tfrc_sp_lh_interval_add(lh, h, =
first_li, sk,
dccp_hdr(skb)->dccph_ccval);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Also combinations of loss and ECN-marks (a=
s per the warning)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* are not supported. The permutations of los=
s combined with or
