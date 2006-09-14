From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:12:07 +0000
Subject: [PATCH 6/10]: [DCCP] CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <20060914171207.GG20651@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

If not enough cwnd is available, tell the sender to check again as soon as
possible.  This will increase CPU utilization (polling frequently for cwnd) but
will improve network performance.  That is, the sender will need to wait less
before detecting the increase of cwnd.  A better architecture would be for the
CCID to call-back (or dequeue) from DCCP when it is able to transmit traffic --
not the other way around as it currently occurs.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ccid2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 699a566..e0acd1b 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -122,7 +122,7 @@ static int ccid2_hc_tx_send_packet(struc
 		}
 	}
 
-	return 100; /* XXX */
+	return 1; /* XXX CCID should dequeue when ready instead of polling */
 }
 
 static void ccid2_change_l_ack_ratio(struct sock *sk, int val)
