From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:27 +0000
Subject: [PATCH 05/11] [DCCP]: Make PARTOPEN an autonomous state
Message-Id: <1195658913-24840-6-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This decouples PARTOPEN from TCP-specific stream-states.

It thus addresses the FIXME.

The code has been checked with regard to dependency on PARTOPEN and FIN_WAIT1
states (to which PARTOPEN previously was mapped): there is no difference, as
PARTOPEN is always referred to directly (i.e. not via the mapping to TCP
state).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/dccp.h |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 333c3ea..a007326 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -229,21 +229,13 @@ struct dccp_so_feat {
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
 	DCCP_TIME_WAIT	= TCP_TIME_WAIT,
 	DCCP_CLOSED	= TCP_CLOSE,
-	DCCP_MAX_STATES = TCP_MAX_STATES,
+	DCCP_PARTOPEN	= TCP_MAX_STATES,
+	DCCP_MAX_STATES
 };
 
 #define DCCP_STATE_MASK 0xf
@@ -252,12 +244,12 @@ enum dccp_state {
 enum {
 	DCCPF_OPEN	 = TCPF_ESTABLISHED,
 	DCCPF_REQUESTING = TCPF_SYN_SENT,
-	DCCPF_PARTOPEN	 = TCPF_FIN_WAIT1,
 	DCCPF_LISTEN	 = TCPF_LISTEN,
 	DCCPF_RESPOND	 = TCPF_SYN_RECV,
 	DCCPF_CLOSING	 = TCPF_CLOSING,
 	DCCPF_TIME_WAIT	 = TCPF_TIME_WAIT,
 	DCCPF_CLOSED	 = TCPF_CLOSE,
+	DCCPF_PARTOPEN	 = 1 << DCCP_PARTOPEN,
 };
 
 static inline struct dccp_hdr *dccp_hdr(const struct sk_buff *skb)
-- 
1.5.3.4

