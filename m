From: Burak Gorkemli <burakgmail-dccp@yahoo.com>
Date: Thu, 30 Nov 2006 17:52:08 +0000
Subject: Re: [DCCP]: Fix BUG in send time calculation
Message-Id: <20061130175208.72929.qmail@web30006.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
References: <200611301541.36467@strip-the-willow>
In-Reply-To: <200611301541.36467@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

After applying both of your patches I am able to send packets over DCCP (CCID3). I will do more tests tomorrow and see how it behaves.

Many thanks

----- Original Message ----
From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: Arnaldo de Melo <acme@mandriva.com>; dccp@vger.kernel.org
Sent: Thursday, November 30, 2006 5:41:35 PM
Subject: [DCCP]: Fix BUG in send time calculation

I think I found the bug, see description below.
The problem was clearly in CCID 3, with CCID 2 performance was good.
I think it makes sense to use the other patch (RTO) as well. CCID 3
needs some more work, but I think with this the reported problem is
solved.

------------> Commit Message <---------------------------------
[DCCP]: Fix BUG in retransmission delay calculation

This bug resulted in ccid3_hc_tx_send_packet returning
negative delay values, which in turn triggered silently 
dequeueing packets in dccp_write_xmit. As a result, only a
few out of the submitted packets made it at all onto the network.
Occasionally, when dccp_wait_for_ccid was involved, this also
triggered a bug warning since ccid3_hc_tx_send_packet returned
a negative value (which in reality was a negative delay value).

The cause for this bug lies in the comparison
 
 if (delay >= hctx->ccid3hctx_delta) 
        return delay / 1000L;

The type of `delay' is `long', that of ccid3hctx_delta is `u32'.
When comparing negative long values against u32 values, the test
returned `true' whenever delay was smaller than 0 (meaning the
        packet was overdue to send).

The fix is by casting, subtracting, and then testing the difference
with regard to 0. 

This has been tested and shown to work.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

---
 net/dccp/ccids/ccid3.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -339,7 +339,7 @@ static int ccid3_hc_tx_send_packet(struc
          * else
          *       // send the packet in (t_nom - t_now) milliseconds.
          */
-        if (delay >= hctx->ccid3hctx_delta)
+        if (delay - (long)hctx->ccid3hctx_delta >= 0)
             return delay / 1000L;
         break;
     case TFRC_SSTATE_TERM:


-
To unsubscribe from this list: send the line "unsubscribe dccp" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



