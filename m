From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Jul 2007 14:26:55 +0000
Subject: [PATCH 8/10]: Use maximum-RTO backoff from DCCP spec
Message-Id: <200707121526.55742@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Use maximum-RTO backoff from DCCP spec

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

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

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
