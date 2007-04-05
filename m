From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:33:57 +0000
Subject: [PATCH 10/43]: Provide fallback RTT value when none is available
Message-Id: <200704051633.57832@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Provide fallback RTT value when none is available

This implements RFC 4340, section 3.4:

 "Each DCCP implementation thus defines a default round-trip time
  for use when no estimate is  available.  This parameter should 
  default to not less than 0.2 seconds [...]."

In addition, after consulting with a few TCP experts, the over-cautious upper
bound of 4 seconds for an RTT sample has now been reduced to 3 seconds: to 
match the initial TCP RTO value as specified in [RFC 1122, 4.2.3.1].

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -73,9 +73,12 @@ extern void dccp_time_wait(struct sock *
 
 #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
 
-/* bounds for sampled RTT values from packet exchanges (in usec) */
+/*
+ * RTT sampling: sanity bounds and fallback RTT value from RFC 4340, section 3.4
+ */
 #define DCCP_SANE_RTT_MIN	100
-#define DCCP_SANE_RTT_MAX	(4 * USEC_PER_SEC)
+#define DCCP_FALLBACK_RTT	(USEC_PER_SEC / 5)
+#define DCCP_SANE_RTT_MAX	(3 * USEC_PER_SEC)
 
 /* Maximal interval between probes for local resources.  */
 #define DCCP_RESOURCE_PROBE_INTERVAL ((unsigned)(HZ / 2U))
