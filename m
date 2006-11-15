From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Wed, 15 Nov 2006 21:55:27 +0000
Subject: [BUG] DCCP performance stops on CCID3 at times
Message-Id: <200611161055.31036.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Folks,

Was chatting to Arnaldo about how I was working on this and he suggested to=
 post to list. I'm still working on it but anybody else can feel free to he=
lp!

I was getting the following in my logs sometimes when testing and the conne=
ction would basically stop:
Nov  1 15:16:47 localhost kernel: [15923.523670] dccp_li_hist_calc_i_mean: =
w_tot =3D 0

So I've added some debugs in as per below:
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 788ee0f..e8c9584 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -834,21 +834,21 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	}
=20
 	if (unlikely(step =3D 0)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=3D%p, packet history "
+		printk(KERN_CRIT "%s: %s, sk=3D%p, packet history "
 			       "contains no data packets!\n",
 			       __FUNCTION__, dccp_role(sk), sk);
 		return ~0;
 	}
=20
 	if (unlikely(interval =3D 0)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=3D%p, Could not find a "
+		printk(KERN_CRIT "%s: %s, sk=3D%p, Could not find a "
 			       "win_count interval > 0. Defaulting to 1\n",
 			       __FUNCTION__, dccp_role(sk), sk);
 		interval =3D 1;
 	}
 found:
 	if (!tail) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: tail is null\n",
+		printk(KERN_CRIT "%s: tail is null\n",
 		   __FUNCTION__);
 		return ~0;
 	}
@@ -870,7 +870,7 @@ found:
 	tmp2 =3D (u32)tmp1;
=20
 	if (!tmp2) {
-		LIMIT_NETDEBUG(KERN_WARNING "tmp2 =3D 0 "
+		printk(KERN_CRIT "tmp2 =3D 0 "
 		   "%s: x_recv =3D %u, rtt =3D%u\n",
 		   __FUNCTION__, x_recv, rtt);
 		return ~0;
@@ -882,9 +882,10 @@ found:
 	ccid3_pr_debug("%s, sk=3D%p, receive rate=3D%u bytes/s, implied "
 		       "loss rate=3D%u\n", dccp_role(sk), sk, x_recv, p);
=20
-	if (p =3D 0)
+	if (p =3D 0) {
+		printk(KERN_CRIT "%s: p =3D 0, fval =3D %d\n",__FUNCTION__,fval);
 		return ~0;
-	else
+	} else
 		return 1000000 / p;=20
 }
=20
@@ -896,9 +897,10 @@ static void ccid3_hc_rx_update_li(struct
=20
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
 		if (!dccp_li_hist_interval_new(ccid3_li_hist,
-		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
+		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss)) {
+		   	printk(KERN_CRIT "%s:interval_new failed\n",__FUNCTION__);
 			return;
-
+		}
 		head =3D list_entry(hcrx->ccid3hcrx_li_hist.next,
 		   struct dccp_li_hist_entry, dccplih_node);
 		head->dccplih_interval =3D ccid3_hc_rx_calc_first_li(sk);
@@ -929,6 +931,9 @@ static void ccid3_hc_rx_update_li(struct
 		list_del(tail);
 		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
=20
+		if (seq_temp =3D ~0)
+			printk(KERN_CRIT "%s: seq_temp =3D ~0\n",__FUNCTION__);
+
 		/* Create the newest interval */
 		entry->dccplih_seqno =3D seq_loss;
 		entry->dccplih_interval =3D seq_temp;
---

And now I get these subcases:
Nov  2 21:22:21 localhost kernel: [26564.665163] ccid3_hc_rx_calc_first_li:=
 p =3D 0, fval =3D 7046
This is due to the computed x_recv being very, very low I believe. So it se=
ts it to ~0

Nov  2 21:22:21 localhost kernel: [26564.665381] dccp_li_hist_calc_i_mean: =
w_tot =3D 0
Nov  3 02:27:46 localhost kernel: [44880.646467] ccid3_hc_rx_calc_first_li:=
 server, sk=DC04b16c, Could not find a win_count interval > 0. Defaulting t=
o 1
Nov  3 02:27:46 localhost kernel: [44880.646538] tmp2 =3D 0 ccid3_hc_rx_cal=
c_first_li: x_recv =3D 0, rtt =3D1

These other cases I have to investigate. First is most common though. I thi=
nk I should fix them all.

Other random notes:
This is from dccp_li_hist_calc_i_mean in ccids/lib/loss_interval.c

Because dccp_li_hist_w[i] is static this means that all values of li_entry-=
>dccplih_interval must be ~0.

calc_i_mean is only called by ccid3_hc_rx_packet_recv in ccids/ccid3.c afte=
r a loss has been found. This means that li_entry->dccplih_interval on one =
of the nodes mustn't be getting set.

dccplih_interval only gets altered in ccid3_hc_rx_update_li in ccid3.c. If =
the list is empty it gets created and dccplih_interval gets set to ccid3_hc=
_rx_calc_first_li or alternatively to dccp_delta_seqno result.

dccp_delta_seqno could return ~0 if numbers are reversed. (but this has pro=
ved not to be the case yet)

The spec does say transmission can drop to as low as 1 packet every 64 seco=
nds but some of it is tied up to this I think:
http://www.mail-archive.com/dccp@vger.kernel.org/msg00467.html

