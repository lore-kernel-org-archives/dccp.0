From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 30 Oct 2009 13:07:36 +0000
Subject: Re: ccid-4 [PATCH 1/1]: Add the new prefix scheme also to the
Message-Id: <20091030130736.GA5661@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20091019053231.GF3366@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20091019053231.GF3366@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| > If you are ok with this, I would merge parts of it with the other patch=
es
| > (in particular the first CCID-4 patch, ccid4.patch), in order to make t=
he patch size
| > smaller.
| >
| Yes, I agree.
|=20
I have done this now, below is a summary of the changes.

It also contains a bug fix: CONFIG_IP_DCCP_CCID?_MEASURE_S_AS_...
configuration had been forgotten in the update to the prefix scheme,
it only worked for the (default) of using MPS. Now it is fixed in the
dccp tree as well as in the ccid4 tree.

The main changes are mostly whitespace, so that the ccid3.c - part of
the first CCID-4 patch is now really small. However, several patches
are affected by the prefix change:

 1) The first TFRC-SP patch (since later patches rely on tfrc_hc_{r,t}x_soc=
k),
    this is commit af853645fac8e7bfdef3f6997b05dfdcf0966d9a

 2) The last TFRC-SP patch (again tfrc_ccids_sp.h, tfrc_hc_rx_sock),
    this is commit 84588187fa68e74fed67547675edb179e95db089

 3) The first sender-side TFRC-SP patch (again tfrc_ccids_sp.h, tfrc_hc_tx_=
sock),
    this is commit=20

 4) The first CCID-4 patch (as discussed, ccid3-part now smaller, ccid4.c u=
pdated
    accordingly), this is commit 629ed5e8be5cbe18efe91e0dea32939a39c3751e

 5) The second CCID-4 patch needed to be modified since it did no longer ap=
ply
    after the changes to (4), this is 33a78b0687e3f775d85961693275660a99665=
c6f
   =20
Below is also a diff against the previous state: mostly whitespace
changes and things that were reverted in ccid3.c.

Please have a look at=20
 http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dshor=
tlog;h=CCid4
 git://eden-feed.erg.abdn.ac.uk/dccp_exp  [subtree 'ccid4']

I have checked and compile-tested the updates.

And here are the global changes to before:
------------------------------------------
 ccid3.c             |   30 +++++++++++++++---------------
 ccid4.c             |    6 +++---
 lib/tfrc_ccids_sp.h |    3 +--
 3 files changed, 19 insertions(+), 20 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -58,7 +58,7 @@ static int ccid3_osc_prev =3D true;
 static void ccid3_update_send_interval(struct tfrc_hc_tx_sock *hc)
 {
 	if (unlikely(hc->tx_x <=3D hc->tx_s))
-		hc->tx_x	=3D hc->tx_s;
+		hc->tx_x =3D hc->tx_s;
 	hc->tx_t_ipi =3D scaled_div32(((u64)hc->tx_s) << 6, hc->tx_x);
 }
=20
@@ -75,8 +75,8 @@ static void ccid3_update_send_interval(struct tfrc_hc_tx_=
sock *hc)
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
 	struct tfrc_hc_tx_sock *hc =3D tfrc_hc_tx_sk(sk);
-	u64 min_rate =3D 2 * hc->tx_x_recv;
-	const u64 old_x =3D hc->tx_x;
+	__u64 min_rate =3D 2 * hc->tx_x_recv;
+	const __u64 old_x =3D hc->tx_x;
 	ktime_t now =3D stamp ? *stamp : ktime_get_real();
=20
 	/*
@@ -92,13 +92,13 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime=
_t *stamp)
=20
 	if (hc->tx_p > 0) {
=20
-		hc->tx_x =3D min(((u64)hc->tx_x_calc) << 6, min_rate);
+		hc->tx_x =3D min(((__u64)hc->tx_x_calc) << 6, min_rate);
=20
 	} else if (ktime_us_delta(now, hc->tx_t_ld) - (s64)hc->tx_rtt >=3D 0) {
=20
 		hc->tx_x =3D min(2 * hc->tx_x, min_rate);
 		hc->tx_x =3D max(hc->tx_x,
-			      scaled_div(((u64)hc->tx_s) << 6, hc->tx_rtt));
+			       scaled_div(((__u64)hc->tx_s) << 6, hc->tx_rtt));
 		hc->tx_t_ld =3D now;
 	}
=20
@@ -119,9 +119,9 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime=
_t *stamp)
 static u32 ccid3_hc_tx_measure_packet_size(struct sock *sk, const u16 new_=
len)
 {
 #if   defined(CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_AVG)
-	return tfrc_ewma(tfrc_hc_tx_sk(sk)->s, new_len, 9);
+	return tfrc_ewma(tfrc_hc_tx_sk(sk)->tx_s, new_len, 9);
 #elif defined(CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_MAX)
-	return max(tfrc_hc_tx_sk(sk)->s, new_len);
+	return max(tfrc_hc_tx_sk(sk)->tx_s, new_len);
 #else /* CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_MPS	*/
 	return dccp_sk(sk)->dccps_mss_cache;
 #endif
@@ -188,7 +188,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long=
 data)
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hc->tx_t_rto =3D 0))		/* no feedback received yet */
+	if (unlikely(hc->tx_t_rto =3D 0))	/* no feedback received yet */
 		t_nfb =3D TFRC_INITIAL_TIMEOUT;
 	else
 		t_nfb =3D max(hc->tx_t_rto, 2 * hc->tx_t_ipi);
@@ -224,8 +224,8 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, str=
uct sk_buff *skb)
=20
 	if (hc->tx_s =3D 0) {
 		sk_reset_timer(sk, &hc->tx_no_feedback_timer, (jiffies +
-				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hc->tx_last_win_count   =3D 0;
+			       usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
+		hc->tx_last_win_count	=3D 0;
 		hc->tx_t_last_win_count =3D now;
=20
 		/* Set t_0 for initial packet */
@@ -249,7 +249,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, str=
uct sk_buff *skb)
 			 * - set sending rate X_pps =3D 1pps as per RFC 3448, 4.2.
 			 */
 			hc->tx_rtt =3D DCCP_FALLBACK_RTT;
-			hc->tx_x	  =3D dp->dccps_mss_cache;
+			hc->tx_x   =3D dp->dccps_mss_cache;
 			hc->tx_x <<=3D 6;
 		}
=20
@@ -391,7 +391,7 @@ done_computing_x:
 		 */
 		if (r_sample > hc->tx_r_sqmean && hc->tx_p > 0)
 			hc->tx_t_ipi =3D div_u64((u64)hc->tx_t_ipi * (u64)r_sample,
-					      hc->tx_r_sqmean);
+					       hc->tx_r_sqmean);
 		hc->tx_t_ipi =3D min_t(u32, hc->tx_t_ipi, TFRC_T_MBI);
 		/* update R_sqmean _after_ computing the modulation factor */
 		hc->tx_r_sqmean =3D tfrc_ewma(hc->tx_r_sqmean, r_sample, 9);
@@ -413,7 +413,7 @@ done_computing_x:
 	 * often ('spinning') on LANs with small RTTs.
 	 */
 	hc->tx_t_rto =3D max_t(u32, 4 * hc->tx_rtt, (CONFIG_IP_DCCP_CCID3_RTO *
-						 (USEC_PER_SEC / 1000)));
+						       (USEC_PER_SEC / 1000)));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =3D  max(t_RTO, 2 * t_ipi)
@@ -471,7 +471,7 @@ static int ccid3_hc_tx_init(struct ccid *ccid, struct s=
ock *sk)
=20
 	hc->tx_hist  =3D NULL;
 	setup_timer(&hc->tx_no_feedback_timer,
-		    ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
+			ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
 	return 0;
 }
=20
@@ -583,7 +583,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 prepare_for_next_time:
 	tfrc_rx_hist_restart_byte_counter(&hc->rx_hist);
 	hc->rx_last_counter =3D dccp_hdr(skb)->dccph_ccval;
-	hc->rx_feedback	   =3D fbtype;
+	hc->rx_feedback	    =3D fbtype;
 }
=20
 static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
--- a/net/dccp/ccids/ccid4.c
+++ b/net/dccp/ccids/ccid4.c
@@ -147,9 +147,9 @@ static void ccid4_hc_tx_update_x(struct sock *sk, ktime=
_t *stamp)
 static u32 ccid4_hc_tx_measure_packet_size(struct sock *sk, const u16 new_=
len)
 {
 #if   defined(CONFIG_IP_DCCP_CCID4_MEASURE_S_AS_AVG)
-	return tfrc_ewma(tfrc_hc_tx_sk(sk)->s, new_len, 9);
+	return tfrc_ewma(tfrc_hc_tx_sk(sk)->tx_s, new_len, 9);
 #elif defined(CONFIG_IP_DCCP_CCID4_MEASURE_S_AS_MAX)
-	return max(tfrc_hc_tx_sk(sk)->s, new_len);
+	return max(tfrc_hc_tx_sk(sk)->tx_s, new_len);
 #else /* CONFIG_IP_DCCP_CCID4_MEASURE_S_AS_MPS	*/
 	return dccp_sk(sk)->dccps_mss_cache;
 #endif
@@ -685,7 +685,7 @@ static void ccid4_hc_rx_send_feedback(struct sock *sk,
 prepare_for_next_time:
 	tfrc_rx_hist_restart_byte_counter(&hc->rx_hist);
 	hc->rx_last_counter =3D dccp_hdr(skb)->dccph_ccval;
-	hc->rx_feedback	   =3D fbtype;
+	hc->rx_feedback	    =3D fbtype;
 }
=20
 static int ccid4_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
--- a/net/dccp/ccids/lib/tfrc_ccids_sp.h
+++ b/net/dccp/ccids/lib/tfrc_ccids_sp.h
@@ -66,7 +66,7 @@ enum tfrc_options {
  * @tx_t_ld:		  Time last doubled during slow start
  * @tx_t_nom:		  Nominal send time of next packet
  * @tx_hist:		  Packet history
- * @tx_li_data:		  FIXME
+ * @tx_li_data:		  Loss interval data for options
  */
 struct tfrc_hc_tx_sock {
 	u64				tx_x;
@@ -126,7 +126,6 @@ enum tfrc_fback_type {
=20
 /**
  * struct tfrc_hc_rx_sock - CCID3/4 receiver half-connection socket
- *
  * @rx_last_counter:	     Tracks window counter (RFC 4342, 8.1)
  * @rx_feedback:	     The type of the feedback last sent
  * @rx_x_recv:		     Receiver estimate of send rate (RFC 3448, sec. 4.3)
