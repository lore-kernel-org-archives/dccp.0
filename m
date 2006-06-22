From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 17:57:34 +0000
Subject: [PATCH 07/11] CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <20060622175734.GG4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

If not enough cwnd is available, tell the sender to check again as soon as
possible.  This will increase CPU utilization (polling frequently for cwnd) but
will improve network performance.  That is, the sender will need to wait less
before detecting the increase of cwnd.  A better architecture would be for the
CCID to call-back (or dequeue) from DCCP when it is able to transmit
traffic---not the other way around as it currently occurs.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index c11201b..b2d140f 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -160,7 +160,7 @@ static int ccid2_hc_tx_send_packet(struc
 		}
 	}
 
-	return 100; /* XXX */
+	return 1; /* XXX CCID should dequeue when ready instead of polling */
 }
 
 static void ccid2_change_l_ack_ratio(struct sock *sk, int val)
