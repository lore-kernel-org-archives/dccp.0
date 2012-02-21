From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Feb 2012 15:05:20 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <20120221150520.GA3723@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here is a patch that can be used in place of enabling the debug messages.
It may be easier to use this, especially if it takes long to reproduce the bug.

From a quick look it seems that x_calc = 0 will do no harm in the old code, since
ccid3_hc_tx_update_x() is called subsequently, it will set x to s/t_mbi

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -237,7 +237,11 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hc->tx_p && !hc->tx_x_calc);
+		if (hc->tx_p && !hc->tx_x_calc)
+			DCCP_CRIT("ERROR: s=%u, p=%u, x_calc = %u, x_recv = %llu, X = %llu",
+				hc->tx_s, hc->tx_p, hc->tx_x_calc,
+				(unsigned long long)hc->tx_x_recv,
+				(unsigned long long)hc->tx_x);
 
 		if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
 			hc->tx_x_recv 