From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 01 Aug 2007 14:27:23 +0000
Subject: Re: [PATCHv2 5/5]: Revert use of MSS instead of s
Message-Id: <200708011527.23446@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708011507.58199@strip-the-willow>
In-Reply-To: <200708011507.58199@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Anyone noted the this? Had to change it again, the interdiff is below. This is one 
of the reasons why tracking drafts is a nightmare ... changes all over the place.
Have put this updated version into the test tree.

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -335,7 +335,7 @@ static int ccid3_hc_tx_send_packet(struc
                        hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
                        hctx->ccid3hctx_t_ld = now;
                } else {
-                       /* Sender does not have RTT sample: X = MSS/second */
+                       /* Sender does not have RTT sample: X_pps = 1 pkt/sec */
                        hctx->ccid3hctx_x = hctx->ccid3hctx_s;
                        hctx->ccid3hctx_x <<= 6;

