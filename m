From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:37:05 +0000
Subject: [PATCH 37/43]: Use maxiumum-RTO backoff from DCCP spec
Message-Id: <200704051637.05406@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Use maxiumum-RTO backoff from DCCP spec

This removes another Fixme, using the TCP maximum RTO rather than the value
specified by the DCCP specification. Across the sections in RFC 4340, 64
seconds is consistently suggested as maximum RTO backoff value; and this is
the value which is now used.

I have checked both termination cases for retransmissions of Close/CloseReq: 
with the default value 15 of `retries2', and an initial icsk_retransmit = 0,
it takes about 614 seconds to declare a non-responding peer as dead, after
which the final terminating Reset is sent. With the TCP maximum RTO value of
120 seconds it takes (as might be expected) almost twice as long, about 23
minutes.

         Detailed References [can be omitted from commit msg]
         ----------------------------------------------------

Maximum RTO backoff affects the following sections of the code:

 * Feature negotiation
   The section on feature negotiation in RFC 4340, section 6.6.3,
   states that "Endpoints SHOULD use an exponential-backoff timer 
   [...] and should back off to not less than 64 seconds."
   The DCCP feature negotiation (options.c and in timer.c) use RTO_MAX
   as upper bound, so using the new default of 64 seconds makes sense.
 
 * Requests in the client-REQUEST state (section 8.1.1) are also subject
   to an exponential backoff using the same upper bound.
   This timer is set in dccp_connect(), using again RTO_MAX.
 
 * Sending Close/CloseReq in the states CLOSING and CLOSEREQ (sec. 8.3) is
   subject to the same maximum backoff of "not less than once every 64 seconds"
   This is done in dccp_send_close, again using RTO_MAX.

 * The dccp_response_timer() (used by dccp_keepalive_timer) also uses RTO_MAX.
   This timer performs garbage-collection of older entries in the listen queue
   in inet_csk_reqsk_queue_prune, where RTO_MAX sets the upper bound on expiry
   of an entry. It is thus probably best to keep RTO_MAX consistent with the
   other timeouts, i.e. use the same value here.
 
 * Acks in client-PARTOPEN state (sec. 8.1.5) are also to be retransmitted
   using a delayed-Ack timer. This is done in dccp_write_xmit().
 
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -71,7 +71,14 @@ extern void dccp_time_wait(struct sock *
 /* RFC 1122, 4.2.3.1 initial RTO value */
 #define DCCP_TIMEOUT_INIT ((unsigned)(3 * HZ))
 
-#define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
+/*
+ * The maximum back-off value for retransmissions. This is needed for
+ *  - retransmitting client-Requests (sec. 8.1.1),
+ *  - retransmitting Close/CloseReq when closing (sec. 8.3),
+ *  - feature-negotiation retransmission (sec. 6.6.3),
+ *  - Acks in client-PARTOPEN state (sec. 8.1.5).
+ */
+#define DCCP_RTO_MAX ((unsigned)(64 * HZ))
 
 /*
  * RTT sampling: sanity bounds and fallback RTT value from RFC 4340, section 3.4
@@ -439,7 +446,7 @@ static inline void timeval_add_usecs(str
 {
 	tv->tv_usec += usecs;
 	while (tv->tv_usec >= USEC_PER_SEC) {
-		tv->tv_sec++;
+
 		tv->tv_usec -= USEC_PER_SEC;
 	}
 }
