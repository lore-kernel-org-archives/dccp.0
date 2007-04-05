From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:36:25 +0000
Subject: [PATCH 30/43]: Separate protocol states into general/specific
Message-Id: <200704051636.25556@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Separate protocol states into general/specific

This prepares a separation of DCCP protocol states into
 * those which have a generalisation as `stream' states and
 * those which are specific to DCCP and do not generalise well.
For this purpose, the existing TCP_MAX_STATES is inserted as
separator; everything between TCP_MAX_STATES and DCCP_MAX_STATES
is private to DCCP.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -242,7 +242,9 @@ enum dccp_state {
 	DCCP_CLOSING	= TCP_CLOSING,
 	DCCP_TIME_WAIT	= TCP_TIME_WAIT,
 	DCCP_CLOSED	= TCP_CLOSE,
-	DCCP_MAX_STATES = TCP_MAX_STATES,
+	/* Everything below here is specific to DCCP only */
+	DCCP_INTRINSICS = TCP_MAX_STATES,
+	DCCP_MAX_STATES
 };
 
 #define DCCP_STATE_MASK 0xf
