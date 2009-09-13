From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 13 Sep 2009 16:12:24 +0000
Subject: Re: [PATCH 2/5] Implement loss counting on TFRC-SP receiver
Message-Id: <20090913161224.GA5121@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
In-Reply-To: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Implement loss counting on TFRC-SP receiver. 
| Consider transmission's hole size as loss count.
The implementation of loss counts as the basis for Dropped Packet option has
problems and can in its current form not be used. Please see below.


--- dccp_tree_work4.orig/net/dccp/ccids/lib/loss_interval_sp.c
+++ dccp_tree_work4/net/dccp/ccids/lib/loss_interval_sp.c
@@ -187,6 +187,7 @@
 		s64 len = dccp_delta_seqno(cur->li_seqno, cong_evt_seqno);
 		if ((len <= 0) ||
 		    (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval))) {
+			cur->li_losses += rh->num_losses;
 			return false;
 		}
This has a multiplicative effect, since rh->num_losses is added to cur->li_losses
each time the condition is evaluated. E.g. if 3 times in a row reordered (earlier)
sequence numbers arrive, or if the CCvals do not differ (high-speed networks),
we end up with 3 * rh->num_losses, which can't be correct.



--- dccp_tree_work4.orig/net/dccp/ccids/lib/packet_history_sp.c
+++ dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.c
@@ -244,6 +244,7 @@
 		h->loss_count = 3;
 		tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 3),
 					       skb, n3);
+		h->num_losses = dccp_loss_count(s2, s3, n3);
 		return 1;
 	}
This only measures the gap between s2 and s3, but the "hole" starts at s0,
so it would need to be dccp_loss_count(s0, s3, n3). Algorithm is documented at
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/\
ccid3/ccid3_packet_reception/loss_detection/loss_detection_algorithm_notes.txt
 
@@ -257,6 +258,7 @@
 		tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 2),
 					       skb, n3);
 		h->loss_count = 3;
+		h->num_losses = dccp_loss_count(s1, s3, n3);
 		return 1;
 	}
In this case, the "hole" is between s0 and s2, it is case VI(d) in the above.
 
@@ -293,6 +295,7 @@
 	h->loss_start = tfrc_rx_hist_index(h, 3);
 	tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 1), skb, n3);
 	h->loss_count = 3;
+	h->num_losses = dccp_loss_count(s0, s3, n3);
 
 	return 1;
 }
Here it is also between s0 and s2, not between s0 and s3. It is case VI(c.3).

However, the above still is a crude approximation, since it only measures between
the last sequence number received before the loss and the third sequence number
after the loss. It would be better to either

 * use the first sequence number after the loss (this can be s1, s2, or s3) or
 * check if there are more holes between the first/second and the second/third
   sequence numbers after the loss.

The second option would be the correct one, it should also take the NDP counts
of each gap into account. And already we have a fairly complicated algorithm.
 		  
Another observation is that this function is only called in packet_history_sp.c,
and only in __two_after_loss(), so that dccp_loss_count() could be made static,
and without the need for the WARN_ON (see below), since in all above cases it is
ensured that the first sequence number argument is "before" the second one.


--- dccp_tree_work4.orig/net/dccp/ccids/lib/packet_history_sp.h
+++ dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.h
@@ -113,6 +113,7 @@
 	u32			  packet_size,
 				  bytes_recvd;
 	ktime_t			  bytes_start;
+	u8			  num_losses;
 };
No more than 255 losses? NDP count option has space for up to 6 bytes, i.e. 2^48-1.
Suggest u64 for consistency with the other parts.
 

--- dccp_tree_work4.orig/net/dccp/dccp.h
+++ dccp_tree_work4/net/dccp/dccp.h
@@ -168,6 +168,21 @@
 	return (u64)delta <= ndp + 1;
 }
 
+static inline u64 dccp_loss_count(const u64 s1, const u64 s2, const u64 ndp)
+{
+	s64 delta, count;
+
+	delta = dccp_delta_seqno(s1, s2);
+	WARN_ON(delta < 0);
+
+	count = ndp + 1;
+	count -= delta;
+
+	count = (count > 0) ? count : 0;
+
+	return (u64) count;
+}
Let S_A, S_B be sequence numbers such that S_B is "after" S_A, and let
N_B be the NDP count of packet S_B. Then, using module-2^48 arithmetic,
 D = S_B - S_A - 1  is an upper bound of the number of lost data packets,
 D - N_B            is an approximation of the number of lost data 
                    packets (there are cases where this is not exact).

But your formula computes N_B - D, i.e. it negates this value. What you
want is dccp_loss_count(S_A, S_B, N_B) := max(S_B - S_A - 1 - N_B, 0).

A short implementation would be:

/**
 * dccp_loss_count - Approximate the number of data packets lost in a row
 * @s1:   last known sequence number before the loss ('hole')
 * @s2:   first sequence number seen after the 'hole'
 * @ndp:  ndp count associated with packet having sequence number @s2
 */
u64 dccp_loss_count(const u64 s1, const u64 s2, const u64 ndp)
{
	s64 delta = dccp_delta_seqno(s1, s2);
	
	WARN_ON(delta < 0);
	delta -= ndp + 1;

	return delta > 0 ? delta : 0;
}

But then dccp_loss_free reduces to a specialisation of the above:
bool dccp_loss_free(const u64 s1, const u64 s2, const u64 ndp)
{
	return dccp_loss_count(s1, s2, ndp) = 0;
}

But please see above -- the function needs to be called for each hole in a row.
