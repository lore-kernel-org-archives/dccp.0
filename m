From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Jul 2007 14:23:35 +0000
Subject: [PATCH 2/10]: Make PARTOPEN an autonomous state
Message-Id: <200707121523.35353@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Make PARTOPEN an autonomous state

This decouples PARTOPEN from TCP-specific stream-states, as suggested by
the FIXME-comment.

The code has been checked with regard to dependency on PARTOPEN and FIN_WAIT1
states (to which PARTOPEN previously was mapped): there is no difference, as
PARTOPEN is always referred to directly (i.e. not via the mapping to TCP state).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	
---
 include/linux/dccp.h |   12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -228,15 +228,6 @@ struct dccp_so_feat {
 enum dccp_state {
 	DCCP_OPEN	= TCP_ESTABLISHED,
 	DCCP_REQUESTING	= TCP_SYN_SENT,
-	DCCP_PARTOPEN	= TCP_FIN_WAIT1, /* FIXME:
-					    This mapping is horrible, but TCP has
-					    no matching state for DCCP_PARTOPEN,
-					    as TCP_SYN_RECV is already used by
-					    DCCP_RESPOND, why don't stop using TCP
-					    mapping of states? OK, now we don't use
-					    sk_stream_sendmsg anymore, so doesn't
-					    seem to exist any reason for us to
-					    do the TCP mapping here */
 	DCCP_LISTEN	= TCP_LISTEN,
 	DCCP_RESPOND	= TCP_SYN_RECV,
 	DCCP_CLOSING	= TCP_CLOSING,
@@ -244,6 +235,7 @@ enum dccp_state {
 	DCCP_CLOSED	= TCP_CLOSE,
 	/* Everything below here is specific to DCCP only */
 	DCCP_INTRINSICS = TCP_MAX_STATES,
+	DCCP_PARTOPEN,
 	DCCP_MAX_STATES
 };
 
@@ -253,12 +245,12 @@ enum dccp_state {
 enum {
 	DCCPF_OPEN	 = TCPF_ESTABLISHED,
 	DCCPF_REQUESTING = TCPF_SYN_SENT,
-	DCCPF_PARTOPEN	 = TCPF_FIN_WAIT1,
 	DCCPF_LISTEN	 = TCPF_LISTEN,
 	DCCPF_RESPOND	 = TCPF_SYN_RECV,
 	DCCPF_CLOSING	 = TCPF_CLOSING,
 	DCCPF_TIME_WAIT	 = TCPF_TIME_WAIT,
 	DCCPF_CLOSED	 = TCPF_CLOSE,
+	DCCPF_PARTOPEN	 = (1 << (u8)DCCP_PARTOPEN),
 };
 
 static inline struct dccp_hdr *dccp_hdr(const struct sk_buff *skb)
