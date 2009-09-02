From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 02 Sep 2009 02:44:45 +0000
Subject: [PATCH 2/5] Implement loss counting on TFRC-SP receiver
Message-Id: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Implement loss counting on TFRC-SP receiver. Consider transmission's
hole size as loss count.

Changes:
=A0- Adds field li_losses to tfrc_loss_interval to track loss count per int=
erval
=A0- Adds field num_losses to tfrc_rx_hist, used to store loss count per
loss event
=A0- Adds dccp_loss_count function to net/dccp/dccp.h, responsible for
loss count using sequence numbers

Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales
<ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>,
<leandroal@gmail.com>

Index: b/net/dccp/ccids/lib/loss_interval_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/loss_interval_sp.c =A0 =A0=
 2009-08-26
21:50:23.000000000 -0300
+++ b/net/dccp/ccids/lib/loss_interval_sp.c =A0 =A0 2009-08-26
22:51:32.000000000 -0300
@@ -184,6 +184,7 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s64 len =3D dccp_delta_seqno(cur->li_seqno, =
cong_evt_seqno);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((len <=3D 0)||(!tfrc_lh_closed_check(cur,
cong_evt->tfrchrx_ccval)))
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur->li_losses +=3D rh->num_l=
osses;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}

@@ -201,6 +202,7 @@
=A0 =A0 =A0 =A0cur->li_seqno =A0 =A0 =3D cong_evt_seqno;
=A0 =A0 =A0 =A0cur->li_ccval =A0 =A0 =3D cong_evt->tfrchrx_ccval;
=A0 =A0 =A0 =A0cur->li_is_closed =3D false;
+ =A0 =A0 =A0 cur->li_losses =A0 =A0=3D rh->num_losses;

=A0 =A0 =A0 =A0if (++lh->counter =3D 1)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lh->i_mean =3D cur->li_length =3D (*calc_fir=
st_li)(sk);
Index: b/net/dccp/ccids/lib/loss_interval_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/loss_interval_sp.h =A0 =A0=
 2009-08-26
21:30:11.000000000 -0300
+++ b/net/dccp/ccids/lib/loss_interval_sp.h =A0 =A0 2009-08-26
22:52:20.000000000 -0300
@@ -30,12 +30,14 @@
=A0* =A0@li_ccval: =A0 =A0 =A0 =A0 The CCVal belonging to @li_seqno
=A0* =A0@li_is_closed: =A0 =A0 Whether @li_seqno is older than 1 RTT
=A0* =A0@li_length: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Loss interval sequence l=
ength
+ * =A0@li_losses: =A0 =A0 =A0 =A0Number of losses counted on this interval
=A0*/
=A0struct tfrc_loss_interval {
=A0 =A0 =A0 =A0u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0li_seqno:48,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li_ccval:4,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li_is_closed:1;
=A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0li_length;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0li_losses;
=A0};

=A0/**
Index: b/net/dccp/ccids/lib/packet_history_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/packet_history_sp.c =A0 =
=A02009-08-26
21:46:36.000000000 -0300
+++ b/net/dccp/ccids/lib/packet_history_sp.c =A0 =A02009-08-26
22:55:01.000000000 -0300
@@ -236,6 +236,7 @@
=A0 =A0 =A0 =A0if (likely(dccp_delta_seqno(s2, s3) > 0)) { =A0 =A0 /* S2 =
=A0< =A0S3 */
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0h->loss_count =3D 3;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_=
entry(h,
3), skb, n3);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->num_losses =3D dccp_loss_count(s2, s3, n3);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
=A0 =A0 =A0 =A0}

@@ -248,6 +249,7 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_rx_hist_swap(h, 2, 3);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_=
entry(h,
2), skb, n3);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0h->loss_count =3D 3;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->num_losses =3D dccp_loss_count(s1, s3, n3);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
=A0 =A0 =A0 =A0}

@@ -283,6 +285,7 @@
=A0 =A0 =A0 =A0h->loss_start =3D tfrc_rx_hist_index(h, 3);
=A0 =A0 =A0 =A0tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 1), skb=
, n3);
=A0 =A0 =A0 =A0h->loss_count =3D 3;
+ =A0 =A0 =A0 h->num_losses =3D dccp_loss_count(s0, s3, n3);

=A0 =A0 =A0 =A0return 1;
=A0}
Index: b/net/dccp/ccids/lib/packet_history_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/packet_history_sp.h =A0 =
=A02009-08-26
21:40:55.000000000 -0300
+++ b/net/dccp/ccids/lib/packet_history_sp.h =A0 =A02009-08-26
22:55:58.000000000 -0300
@@ -101,6 +101,7 @@
=A0* @packet_size: =A0 =A0 =A0 Packet size in bytes (as per RFC 3448, 3.1)
=A0* @bytes_recvd: =A0 =A0 =A0 Number of bytes received since @bytes_start
=A0* @bytes_start: =A0 =A0 =A0 Start time for counting @bytes_recvd
+ * @num_losses: =A0 =A0 =A0 =A0Number of losses contained on this loss eve=
nt
=A0*/
=A0struct tfrc_rx_hist {
=A0 =A0 =A0 =A0struct tfrc_rx_hist_entry *ring[TFRC_NDUPACK + 1];
@@ -113,6 +114,7 @@
=A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 packet_size,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bytes_re=
cvd;
=A0 =A0 =A0 =A0ktime_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bytes_start;
+ =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0num_losses;
=A0};

=A0/**
Index: b/net/dccp/dccp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/dccp.h =A0 2009-08-25 20:21:45.00000=
0000 -0300
+++ b/net/dccp/dccp.h =A0 2009-08-26 22:59:10.000000000 -0300
@@ -168,6 +168,21 @@
=A0 =A0 =A0 =A0return (u64)delta <=3D ndp + 1;
=A0}

+static inline u64 dccp_loss_count(const u64 s1, const u64 s2, const u64 nd=
p)
+{
+ =A0 =A0 =A0 s64 delta, count;
+
+ =A0 =A0 =A0 delta =3D dccp_delta_seqno(s1, s2);
+ =A0 =A0 =A0 WARN_ON(delta < 0);
+
+ =A0 =A0 =A0 count =3D ndp + 1;
+ =A0 =A0 =A0 count -=3D delta;
+
+ =A0 =A0 =A0 count =3D (count > 0)? count: 0;
+
+ =A0 =A0 =A0 return (u64) count;
+}
+
=A0enum {
=A0 =A0 =A0 =A0DCCP_MIB_NUM =3D 0,
=A0 =A0 =A0 =A0DCCP_MIB_ACTIVEOPENS, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*=
 ActiveOpens */
