From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 09 Jun 2007 18:32:15 +0000
Subject: [PATCH 1/3]: Inline for time delta
Message-Id: <200706091932.15559@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Inline for time delta

This provides a reusable time difference function which returns the difference in
microseconds, as often used in the DCCP code.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    5 +++++
 1 file changed, 5 insertions(+)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -421,6 +421,11 @@ static inline suseconds_t timeval_delta(
 	return secs * USEC_PER_SEC + usecs;
 }
 
+static inline s64 ktime_delta(ktime_t later, ktime_t earlier)
+{
+	return ktime_to_us(ktime_sub(later, earlier));
+}
+
 static inline void timeval_add_usecs(struct timeval *tv,
 				     const suseconds_t usecs)
 {
