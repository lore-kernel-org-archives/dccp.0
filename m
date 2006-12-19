From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 19 Dec 2006 10:07:47 +0000
Subject: Re: [PATCH 0/8]: Sequence numbers, larger windows revisited, minor cleanups
Message-Id: <200612191007.47807@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612151049.50073@strip-the-willow>
In-Reply-To: <200612151049.50073@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Arnaldo / Ian
|  Tomorrow I'll try to review this patch series and take into account
|  your opinion when deciding which ones are pure bug fixes worthy for
|  pushing to DaveM and then to Linus.
I am not fussy about getting the patches into 2.6.20 at all cost. I am reconsidering
the add48/sub48 and the dccp_inc_seqno functions/macros.

The reason is something which I initially didn't consider: Ian reminded me that the
address of a bitfield (e.g. ccid3hcrx_seqno_nonloss). This means that dccp_inc_seqno
is of little use for this purpose - and so are, likely, the add48/sub48 functions.
Please see below for a suggestion of an _inc48() macro which would work in this case.

Since I expect that the sub48/add48 functions will be needed mostly for bitfields and
not for 64-bit values of DCCP internal structures, it may be good to leave those patches
`on ice' and give Ian's patch the preference.

Ian I would appreciate input on how and where such subtraction/addition functions shall
be used. Maybe it is better to just just a set of macros, ditch the sub48/add48 functions.

Gerrit

+++ b/net/dccp/dccp.h
@@ -102,6 +102,7 @@ extern int  sysctl_dccp_tx_qlen;
 #define TO_UNSIGNED48(x) (((x) >= 0)?	       (x) :  COMPLEMENT48(-(x)))
 #define _add48(a, b)	 (((a) + (b)) & DCCP_MAX_SEQNO)
 #define _sub48(a, b)	 _add48((a), COMPLEMENT48((b)))
+#define _inc48(seqno)	 (seqno) = _add48((seqno), 1)
 
 static inline void dccp_set_seqno(u64 *seqno, u64 value)
 {
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -981,10 +981,8 @@ static int ccid3_hc_rx_detect_loss(struc
 		loss = 1;
 		ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
 		   hcrx->ccid3hcrx_ccval_nonloss);
+		_inc48(hcrx->ccid3hcrx_seqno_nonloss);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
-		dccp_inc_seqno(&tmp_seqno);
-		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
-		dccp_inc_seqno(&tmp_seqno);
 		while (dccp_rx_hist_find_entry(&hcrx->ccid3hcrx_hist,
 		   tmp_seqno, &ccval)) {
 			hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;

