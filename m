From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 04 Sep 2009 12:25:01 +0000
Subject: [PATCH 2/5] Implement loss counting on TFRC-SP receiver
Message-Id: <1252067101.6172.2.camel@localhost>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
In-Reply-To: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Implement loss counting on TFRC-SP receiver. Consider transmission's
hole size as loss count.

Changes:
- Adds field li_losses to tfrc_loss_interval to track loss count per
interval
- Adds field num_losses to tfrc_rx_hist, used to store loss count per
loss event
- Adds dccp_loss_count function to net/dccp/dccp.h, responsible for loss
count using sequence numbers

Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales
<ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>,
<leandroal@gmail.com>

Index: dccp_tree_work4/net/dccp/ccids/lib/loss_interval_sp.c
=================================--- dccp_tree_work4.orig/net/dccp/ccids/lib/loss_interval_sp.c
2009-09-03 22:58:17.000000000 -0300
+++ dccp_tree_work4/net/dccp/ccids/lib/loss_interval_sp.c 2009-09-03
23:00:24.000000000 -0300
@@ -187,6 +187,7 @@
s64 len = dccp_delta_seqno(cur->li_seqno, cong_evt_seqno);
if ((len <= 0) ||
    (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval))) {
+ cur->li_losses += rh->num_losses;
return false;
}

@@ -204,6 +205,7 @@
cur->li_seqno   = cong_evt_seqno;
cur->li_ccval   = cong_evt->tfrchrx_ccval;
cur->li_is_closed = false;
+ cur->li_losses   = rh->num_losses;

if (++lh->counter = 1)
lh->i_mean = cur->li_length = (*calc_first_li)(sk);
Index: dccp_tree_work4/net/dccp/ccids/lib/loss_interval_sp.h
=================================--- dccp_tree_work4.orig/net/dccp/ccids/lib/loss_interval_sp.h
2009-09-03 22:58:17.000000000 -0300
+++ dccp_tree_work4/net/dccp/ccids/lib/loss_interval_sp.h 2009-09-03
23:00:24.000000000 -0300
@@ -30,12 +30,14 @@
  *  @li_ccval: The CCVal belonging to @li_seqno
  *  @li_is_closed: Whether @li_seqno is older than 1 RTT
  *  @li_length: Loss interval sequence length
+ *  @li_losses: Number of losses counted on this interval
  */
struct tfrc_loss_interval {
u64 li_seqno:48,
li_ccval:4,
li_is_closed:1;
u32 li_length;
+ u32 li_losses;
};

/**
Index: dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.c
=================================--- dccp_tree_work4.orig/net/dccp/ccids/lib/packet_history_sp.c
2009-09-03 22:58:17.000000000 -0300
+++ dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.c 2009-09-03
23:00:24.000000000 -0300
@@ -244,6 +244,7 @@
h->loss_count = 3;
tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 3),
       skb, n3);
+ h->num_losses = dccp_loss_count(s2, s3, n3);
return 1;
}

@@ -257,6 +258,7 @@
tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 2),
       skb, n3);
h->loss_count = 3;
+ h->num_losses = dccp_loss_count(s1, s3, n3);
return 1;
}

@@ -293,6 +295,7 @@
h->loss_start = tfrc_rx_hist_index(h, 3);
tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 1), skb, n3);
h->loss_count = 3;
+ h->num_losses = dccp_loss_count(s0, s3, n3);

return 1;
}
Index: dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.h
=================================--- dccp_tree_work4.orig/net/dccp/ccids/lib/packet_history_sp.h
2009-09-03 22:58:17.000000000 -0300
+++ dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.h 2009-09-03
22:58:29.000000000 -0300
@@ -113,6 +113,7 @@
u32   packet_size,
  bytes_recvd;
ktime_t   bytes_start;
+ u8   num_losses;
};

/**
Index: dccp_tree_work4/net/dccp/dccp.h
=================================--- dccp_tree_work4.orig/net/dccp/dccp.h 2009-09-03 22:58:17.000000000
-0300
+++ dccp_tree_work4/net/dccp/dccp.h 2009-09-03 22:58:29.000000000 -0300
@@ -168,6 +168,21 @@
return (u64)delta <= ndp + 1;
}

+static inline u64 dccp_loss_count(const u64 s1, const u64 s2, const u64
ndp)
+{
+ s64 delta, count;
+
+ delta = dccp_delta_seqno(s1, s2);
+ WARN_ON(delta < 0);
+
+ count = ndp + 1;
+ count -= delta;
+
+ count = (count > 0) ? count : 0;
+
+ return (u64) count;
+}
+
enum {
DCCP_MIB_NUM = 0,
DCCP_MIB_ACTIVEOPENS, /* ActiveOpens */

