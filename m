From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Nov 2006 15:45:26 +0000
Subject: [PATCH 3/6]:  Fix calculation of t_ipi time of scheduled transmission
Message-Id: <200611211545.26551@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Fix calculation of t_ipi time of scheduled transmission

Problem:
--------
 Currently packet transmissions are not scheduled according to [RFC 3448, 4.6] and
 will, in the worst case, be sent later than necessary. If scheduled transmission 
 requires using a delay, the current delay value is also larger as necessary.
 
Solution:
---------
 This patch fixes time and delay calculation for scheduling CCID 3 packets.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>								    



    D e t a i l e d   D e r i v a t i o n   [not meant as commit message]
    ==================================
Background:
-----------
 [RFC 3448, 4.6] specifies the scheduling of packet transmissions with regard to
 scheduling granularity. The calculated sending time is called `nominal' sending
 time t_nom. The initial sending time is called t_0. The first sending time is called
 t_1 = t0 + t_ipi. From then on, successive sending times are calculated as

          t_nom  =  t_(i+1)  =  t_i + t_ipi

 This is illustrated by the ASCII-Art below:


 |<-------------------- t_ipi ------------------->|

 +------------------------------------------------+-----------------------
 |                       |                        |
 |                       |                        |
 +------------------------------------------------+-----------------------
 |            ^          |<------- t_delta ------>|
 |            |          |                        |
 t_i          t_now      t_nom - t_delta          t_nom = t_(i+1)

              |<-----  t_ipi - (t_now - t_i)  --->|


 Due to scheduling granularity, t_nom is not necessarily exactly the same as the
 actual sending time, hence [RFC 3448, 4.6] introduced the following test:

    t_delta = min(t_ipi/2, t_gran/2);      /* t_gran: scheduling granularity */

    if (t_now > t_nom - t_delta)
        // send the packet now
    else
        // send the packet in t_ipi - (t_now - t_i) microseconds

 In the above illustration, t_now was too early for sending (`else' case).


Current state:
--------------
 Currently the code determines nominal send times using the following pseudo-code:
   delay_in_msec = -1/1000 * (t_now - t_nom - t_delta)
                 =  1/1000 * (t_nom + t_delta - t_now)

   if (delay_in_msec > 0)     /* equivalent to t_now <  t_nom + t_delta              */
       return delay_in_msec;  /* i.e. reschedule in (t_nom -(t_now - t_delta))/1000  */
   else                       /* whenever      t_now >= t_nom + t_delta              */
       /* send packet now */
 
 This means that currently

    * the packet is sent now whenever t_now >= t_nom + t_delta
      instead of                      t_now >  t_nom - t_delta
      => this incurs a performance degradation, since 2*t_delta is spent unnecessarily

    * the delay causes the packet to be rescheduled at the following point of time:
           t_now + (t_nom + t_delta - t_now) = t_nom + t_delta 
      Hence again t_delta time units are not used.

Solution:
---------
 The condition `if (t_now > t_nom - t_delta)' from [RFC 3448, 4.6] is equivalent with
 the condition `if (t_nom - t_now < t_delta)' and the delay simplifies (cf. above figure):
   t_ipi - (t_now - t_i)  =  t_i + t_ipi - t_now
	                  =  t_nom - t_now
 Thus we can twice use `t_nom - t_now', which is what the patch does.

---
 net/dccp/ccids/ccid3.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -303,11 +303,19 @@ static int ccid3_hc_tx_send_packet(struc
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		delay = (timeval_delta(&now, &hctx->ccid3hctx_t_nom) -
-		         hctx->ccid3hctx_delta);
-		delay /= -1000;
-		/* divide by -1000 is to convert to ms and get sign right */
-		rc = delay > 0 ? delay : 0;
+		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
+		/*
+		 * 	Scheduling of packet transmissions [RFC 3448, 4.6]
+		 *
+		 * if (t_now > t_nom - delta)
+		 *       // send the packet now
+		 * else
+		 *       // send the packet in (t_nom - t_now) milliseconds.
+		 */
+		if (delay < hctx->ccid3hctx_delta)
+			rc = 0;
+		else
+			rc = delay/1000L;
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
