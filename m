From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 02 Sep 2009 02:46:26 +0000
Subject: [PATCH 5/5] Updating documentation accordingly
Message-Id: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Updating documentation accordingly

Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales
<ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>,
<leandroal@gmail.com>

Index: b/net/dccp/ccids/lib/loss_interval_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/loss_interval_sp.h =A0 =A0=
 2009-08-27
22:37:40.000000000 -0300
+++ b/net/dccp/ccids/lib/loss_interval_sp.h =A0 =A0 2009-08-27
23:02:00.000000000 -0300
@@ -1,6 +1,7 @@
=A0#ifndef _DCCP_LI_HIST_SP_
=A0#define _DCCP_LI_HIST_SP_
=A0/*
+ * =A0Copyright (c) 2009 Federal University of Campina Grande, Embedded
Systems and Pervasive Computing Lab
=A0* =A0Copyright (c) 2007 =A0 The University of Aberdeen, Scotland, UK
=A0* =A0Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zeala=
nd.
=A0* =A0Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
@@ -69,6 +70,15 @@

=A0#endif

+/**
+ * =A0tfrc_loss_data_entry =A0- =A0Holds info about one loss interval
+ * =A0@next: =A0 =A0 =A0 =A0 =A0 =A0 next entry on this linked list
+ * =A0@lossless_length: =A0length of lossless sequence
+ * =A0@ecn_nonce_sum: =A0 =A0ecn nonce sum for this interval
+ * =A0@loss_length: =A0 =A0 =A0length of lossy part
+ * =A0@data_length: =A0 =A0 =A0data length on lossless part
+ * =A0@drop_count: =A0 =A0 =A0 count of dopped packets
+ */
=A0struct tfrc_loss_data_entry {
=A0 =A0 =A0 =A0struct tfrc_loss_data_entry =A0 =A0 *next;
=A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
lossless_length:24;
@@ -78,9 +88,20 @@
=A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
drop_count:24;
=A0};

-#define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH =A0 =A0 28
-#define TFRC_DROP_OPT_MAX_LENGTH =A0 =A0 =A0 =A0 =A0 =A0 =A0 84
+#define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH =A0 =A0 28 =A0 =A0 =A0/* As def=
ined at
section 8.6.1. of RFC 4342 */
+#define TFRC_DROP_OPT_MAX_LENGTH =A0 =A0 =A0 =A0 =A0 =A0 =A0 84 =A0 =A0 =
=A0/* Specified
on section 8.7. of
CCID4 draft */

+/**
+ * =A0tfrc_loss_data =A0- =A0loss interval data
+ * =A0used by loss intervals and dropped packets options
+ * =A0@head: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 linked list containin=
g loss interval data
+ * =A0@counter: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0number of entries
+ * =A0@loss_intervals_opts: =A0 =A0 =A0space necessary for writing tempora=
ry
option data for loss intervals option
+ * =A0@drop_opts: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0same for =
dropped packets option
+ * =A0@last_loss_count: =A0 =A0 =A0 =A0 =A0last loss count (num. of packet=
s after hole on
transmission) observed
+ * =A0@sto_ecn: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ecn's observed while wa=
iting for hole
to be filled or
accepted as missing
+ * =A0@sto_is_data: =A0 =A0 =A0 =A0 =A0 =A0 =A0flags about if packets saw =
were data packets
+ */
=A0struct tfrc_loss_data {
=A0 =A0 =A0 =A0struct tfrc_loss_data_entry =A0 =A0 *head;
=A0 =A0 =A0 =A0u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
counter;
Index: b/net/dccp/ccids/lib/loss_interval_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/loss_interval_sp.c =A0 =A0=
 2009-08-27
22:36:43.000000000 -0300
+++ b/net/dccp/ccids/lib/loss_interval_sp.c =A0 =A0 2009-08-28
21:07:28.000000000 -0300
@@ -1,4 +1,5 @@
=A0/*
+ * =A0Copyright (c) 2009 Federal University of Campina Grande, Embedded
Systems and Pervasive Computing Lab
=A0* =A0Copyright (c) 2007 =A0 The University of Aberdeen, Scotland, UK
=A0* =A0Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zeala=
nd.
=A0* =A0Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
@@ -56,6 +57,12 @@
=A0 =A0 =A0 =A0ld->counter =3D 0;
=A0}

+/**
+ * =A0tfrc_sp_ld_prepare_data =A0- =A0updates arrays on tfrc_loss_data so
they can be sent as options
+ * =A0@loss_count: =A0 =A0 =A0 current loss count (packets after hole on t=
ransmission),
+ * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 used to determine skip length f=
or loss intervals option
+ * =A0@ld: =A0 =A0 =A0 =A0 =A0 =A0 =A0 loss intervals data being updated
+ */
=A0void tfrc_sp_ld_prepare_data(u8 loss_count, struct tfrc_loss_data* ld)
=A0{
=A0 =A0 =A0 =A0u8* li_ofs, *d_ofs;
@@ -184,7 +191,7 @@
=A0}

=A0/**
- * tfrc_lh_update_i_mean =A0- =A0Update the `open' loss interval I_0
+ * tfrc_sp_lh_update_i_mean =A0- =A0Update the `open' loss interval I_0
=A0* This updates I_mean as the sequence numbers increase. As a consequence=
, the
=A0* open loss interval I_0 increases, hence p =3D W_tot/max(I_tot0, I_tot1)
=A0* decreases, and thus there is no need to send renewed feedback.
@@ -232,11 +239,12 @@
=A0 =A0 =A0 =A0return cur->li_is_closed;
=A0}

-/** tfrc_lh_interval_add =A0- =A0Insert new record into the Loss Interval =
database
+/** tfrc_sp_lh_interval_add =A0- =A0Insert new record into the Loss
Interval database
=A0* @lh: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Loss Interval database
=A0* @rh: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Receive history containing a =
fresh loss event
=A0* @calc_first_li: Caller-dependent routine to compute length of first in=
terval
=A0* @sk: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Used by @calc_first_li in cal=
ler-specific
way (subtyping)
+ * @ccval: =A0 =A0 =A0 =A0Current ccval
=A0* Updates I_mean and returns 1 if a new interval has in fact been
added to @lh.
=A0*/
=A0bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *lh, struct
tfrc_rx_hist *rh,
@@ -315,6 +323,14 @@
=A0 =A0 =A0 =A0return true;
=A0}

+/**
+ * =A0tfrc_sp_update_li_data =A0- =A0Update tfrc_loss_data upon packet
receiving or loss detection
+ * =A0@ld: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_loss_data bein=
g updated
+ * =A0@rh: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loss event record
+ * =A0@skb: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0received packet
+ * =A0@new_loss: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dictates if new loss was =
detected upon receiving
current packet
+ * =A0@new_event: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0...and if=
 the loss starts new
loss interval
+ */
=A0void tfrc_sp_update_li_data(struct tfrc_loss_data *ld, struct
tfrc_rx_hist *rh, struct sk_buff *skb, bool new_loss, bool new_event)
=A0{
=A0 =A0 =A0 =A0struct tfrc_loss_data_entry* new, *h;
Index: b/net/dccp/ccids/lib/packet_history_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/packet_history_sp.c =A0 =
=A02009-08-27
22:36:43.000000000 -0300
+++ b/net/dccp/ccids/lib/packet_history_sp.c =A0 =A02009-08-28
21:05:35.000000000 -0300
@@ -4,6 +4,12 @@
=A0*
=A0* =A0An implementation of the DCCP protocol
=A0*
+ * =A0Copyright (c) 2009 Ivo Calado, Erivaldo Xavier, Leandro Sales
+ *
+ * =A0This code has been developed by the Federal University of Campina Gr=
ande
+ * =A0Embedded Systems and Pervasive Computing Lab. For further
information please see
+ * =A0http://embedded.ufcg.edu.br/ <ivocalado@embedded.ufcg.edu.br>,
<desadoc@gmail.com>, <leandroal@gmail.com>
+ *
=A0* =A0This code has been developed by the University of Waikato WAND
=A0* =A0research group. For further information please see http://www.wand.=
net.nz/
=A0* =A0or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
@@ -323,9 +329,10 @@
=A0}

=A0/**
- * =A0tfrc_rx_congestion_event =A0- =A0Loss detection and further processi=
ng
+ * =A0tfrc_sp_rx_congestion_event =A0- =A0Loss detection and further proce=
ssing
=A0* =A0@h: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0The non-empty RX history object
=A0* =A0@lh: =A0 =A0 =A0 Loss Intervals database to update
+ * =A0@ld: =A0 =A0 =A0 loss data for options
=A0* =A0@skb: =A0 =A0 =A0Currently received packet
=A0* =A0@ndp: =A0 =A0 =A0The NDP count belonging to @skb
=A0* =A0@first_li: Caller-dependent computation of first loss interval in @=
lh
@@ -476,7 +483,7 @@
=A0}

=A0/**
- * tfrc_rx_hist_sample_rtt =A0- =A0Sample RTT from timestamp / CCVal
+ * tfrc_sp_rx_hist_sample_rtt =A0- =A0Sample RTT from timestamp / CCVal
=A0* Based on ideas presented in RFC 4342, 8.1. This function expects
that no loss
=A0* is pending and uses the following history entries (via rtt_sample_prev=
):
=A0* - h->ring[0] =A0contains the most recent history entry prior to @skb;
Index: b/net/dccp/ccids/lib/packet_history_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/packet_history_sp.h =A0 =
=A02009-08-27
22:36:43.000000000 -0300
+++ b/net/dccp/ccids/lib/packet_history_sp.h =A0 =A02009-08-27
23:04:28.000000000 -0300
@@ -1,6 +1,12 @@
=A0/*
=A0* =A0Packet RX/TX history data structures and routines for TFRC-based pr=
otocols.
=A0*
+ * =A0Copyright (c) 2009 Ivo Calado, Erivaldo Xavier, Leandro Sales
+ *
+ * =A0This code has been developed by the Federal University of Campina Gr=
ande
+ * =A0Embedded Systems and Pervasive Computing Lab. For further
information please see
+ * =A0http://embedded.ufcg.edu.br/ <ivocalado@embedded.ufcg.edu.br>,
<desadoc@gmail.com>, <leandroal@gmail.com>
+ *
=A0* =A0Copyright (c) 2007 =A0 The University of Aberdeen, Scotland, UK
=A0* =A0Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zeala=
nd.
=A0*
Index: b/net/dccp/ccids/lib/tfrc_ccids_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/tfrc_ccids_sp.c =A0 =A0 =
=A0 =A02009-08-27
22:36:43.000000000 -0300
+++ b/net/dccp/ccids/lib/tfrc_ccids_sp.c =A0 =A0 =A0 =A02009-08-27
23:09:18.000000000 -0300
@@ -1,4 +1,5 @@
=A0/*
+ * =A0Copyright (c) 2009 Federal University of Campina Grande, Embedded
Systems and Pervasive Computing Lab
=A0* =A0Copyright (c) 2007 Leandro Melo de Sales <leandroal@gmail.com>
=A0* =A0Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
=A0* =A0Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Index: b/net/dccp/ccids/lib/tfrc_ccids_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/tfrc_ccids_sp.h =A0 =A0 =
=A0 =A02009-08-27
22:36:43.000000000 -0300
+++ b/net/dccp/ccids/lib/tfrc_ccids_sp.h =A0 =A0 =A0 =A02009-08-27
23:11:00.000000000 -0300
@@ -1,4 +1,5 @@
=A0/*
+ * =A0Copyright (c) 2009 Federal University of Campina Grande, Embedded
Systems and Pervasive Computing Lab
=A0* =A0Copyright (c) 2007 Leandro Melo de Sales <leandroal@gmail.com>
=A0* =A0Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
=A0* =A0Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Index: b/net/dccp/ccids/lib/tfrc_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/tfrc_sp.c =A0 =A0 =A02009-=
08-27 22:36:43.000000000 -0300
+++ b/net/dccp/ccids/lib/tfrc_sp.c =A0 =A0 =A02009-08-27 23:25:50.000000000=
 -0300
@@ -1,6 +1,9 @@
=A0/*
=A0* TFRC library initialisation
=A0*
+ * Copyright (c) 2009 Federal University of Campina Grande, Embedded
Systems and Pervasive Computing Lab
+ * =A0 =A0 Almost copied from tfrc.c, only renamed symbols
+ *
=A0* Copyright (c) 2007 The University of Aberdeen, Scotland, UK
=A0* Copyright (c) 2007 Arnaldo Carvalho de Melo <acme@redhat.com>
=A0*/
Index: b/net/dccp/ccids/lib/tfrc_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/tfrc_sp.h =A0 =A0 =A02009-=
08-27 22:36:43.000000000 -0300
+++ b/net/dccp/ccids/lib/tfrc_sp.h =A0 =A0 =A02009-08-27 23:28:55.000000000=
 -0300
@@ -1,6 +1,7 @@
=A0#ifndef _TFRC_SP_H_
=A0#define _TFRC_SP_H_
=A0/*
+ * =A0Copyright (c) 2009 Federal University of Campina Grande, Embedded
Systems and Pervasive Computing Lab
=A0* =A0Copyright (c) 2007 =A0 The University of Aberdeen, Scotland, UK
=A0* =A0Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zeala=
nd.
=A0* =A0Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
Index: b/net/dccp/ccids/lib/tfrc_equation_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- a/net/dccp/ccids/lib/tfrc_equation_sp.c =A0 =A0=
 2009-08-27
22:36:43.000000000 -0300
+++ b/net/dccp/ccids/lib/tfrc_equation_sp.c =A0 =A0 2009-08-28
21:08:54.000000000 -0300
@@ -1,4 +1,5 @@
=A0/*
+ * =A0Copyright (c) 2009 Federal University of Campina Grande, Embedded
Systems and Pervasive Computing Lab
=A0* =A0Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
=A0* =A0Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
=A0* =A0Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
@@ -607,7 +608,7 @@
=A0}

=A0/**
- * tfrc_calc_x - Calculate the send rate as per section 3.1 of RFC3448
+ * tfrc_sp_calc_x - Calculate the send rate as per section 3.1 of RFC3448
=A0*
=A0* =A0@s: packet size =A0 =A0 =A0 =A0 =A0in bytes
=A0* =A0@R: RTT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scaled by 1000000 =A0 (i=
.e., microseconds)
@@ -666,7 +667,7 @@
=A0}

=A0/**
- * =A0tfrc_calc_x_reverse_lookup =A0- =A0try to find p given f(p)
+ * =A0tfrc_sp_calc_x_reverse_lookup =A0- =A0try to find p given f(p)
=A0*
=A0* =A0@fvalue: function value to match, scaled by 1000000
=A0* =A0Returns closest match for p, also scaled by 1000000
@@ -699,7 +700,7 @@
=A0}

=A0/**
- * tfrc_invert_loss_event_rate =A0- =A0Compute p so that 10^6 corresponds =
to 100%
+ * tfrc_sp_invert_loss_event_rate =A0- =A0Compute p so that 10^6
corresponds to 100%
=A0* When @loss_event_rate is large, there is a chance that p is truncated =
to 0.
=A0* To avoid re-entering slow-start in that case, we set p TFRC_SMALLEST_P=
 > 0.
=A0*/
