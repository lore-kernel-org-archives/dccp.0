From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 28 Nov 2007 08:35:09 +0000
Subject: [PATCH 2/4]: Dedicated auxiliary states to support passive-close
Message-Id: <11962389112696-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Dedicated auxiliary states to support passive-close

This adds two auxiliary states to deal with passive closes:
  * PASSIVE_CLOSE    (reached from OPEN via reception of Close)    and
  * PASSIVE_CLOSEREQ (reached from OPEN via reception of CloseReq)
as internal intermediate states.	

These states are used to allow a receiver to process unread data before 
acknowledging the received connection-termination-request (the Close/CloseReq).

Without such support, it will happen that passively-closed sockets enter CLOSED
state while there is still unprocessed data in the queue; leading to unexpected
and erratic API behaviour.

PASSIVE_CLOSE has been mapped into TCPF_CLOSE_WAIT, so that the code will seamlessly
work with inet_accept() (which tests for this state).

The state names are thanks to Arnaldo, who suggested this naming scheme following
an earlier revision of this patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   56 +++++++++++++++++++++++++++++++++++----------------
 net/dccp/proto.c     |   22 ++++++++++----------
 2 files changed, 51 insertions(+), 27 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -227,29 +227,51 @@ struct dccp_so_feat {
 #include <net/tcp_states.h>
 
 enum dccp_state {
-	DCCP_OPEN	= TCP_ESTABLISHED,
-	DCCP_REQUESTING	= TCP_SYN_SENT,
-	DCCP_LISTEN	= TCP_LISTEN,
-	DCCP_RESPOND	= TCP_SYN_RECV,
-	DCCP_CLOSING	= TCP_CLOSING,
-	DCCP_TIME_WAIT	= TCP_TIME_WAIT,
-	DCCP_CLOSED	= TCP_CLOSE,
-	DCCP_PARTOPEN	= TCP_MAX_STATES,
+	DCCP_OPEN	     = TCP_ESTABLISHED,
+	DCCP_REQUESTING	     = TCP_SYN_SENT,
+	DCCP_LISTEN	     = TCP_LISTEN,
+	DCCP_RESPOND	     = TCP_SYN_RECV,
+	/*
+	 * States involved in closing a DCCP connection:
+	 * 1) ACTIVE_CLOSEREQ is entered by a server sending a CloseReq.
+	 *
+	 * 2) CLOSING can have three different meanings (RFC 4340, 8.3):
+	 *  a. Client has performed active-close, has sent a Close to the server
+	 *     from state OPEN or PARTOPEN, and is waiting for the final Reset
+	 *     (in this case, SOCK_DONE = 1).
+	 *  b. Client is asked to perform passive-close, by receiving a CloseReq
+	 *     in (PART)OPEN state. It sends a Close and waits for final Reset
+	 *     (in this case, SOCK_DONE = 0).
+	 *  c. Server performs an active-close as in (a), keeps TIMEWAIT state.
+	 *
+	 * 3) The following intermediate states are employed to give passively
+	 *    closing nodes a chance to process their unread data:
+	 *    - PASSIVE_CLOSE    (from OPEN => CLOSED) and
+	 *    - PASSIVE_CLOSEREQ (from (PART)OPEN to CLOSING; case (b) above).
+	 */
+	DCCP_ACTIVE_CLOSEREQ = TCP_FIN_WAIT1,
+	DCCP_PASSIVE_CLOSE   = TCP_CLOSE_WAIT,	/* any node receiving a Close */
+	DCCP_CLOSING	     = TCP_CLOSING,
+	DCCP_TIME_WAIT	     = TCP_TIME_WAIT,
+	DCCP_CLOSED	     = TCP_CLOSE,
+	DCCP_PARTOPEN	     = TCP_MAX_STATES,
+	DCCP_PASSIVE_CLOSEREQ,			/* clients receiving CloseReq */
 	DCCP_MAX_STATES
 };
 
-#define DCCP_STATE_MASK 0xf
+#define DCCP_STATE_MASK 0x1f
 #define DCCP_ACTION_FIN (1<<7)
 
 enum {
-	DCCPF_OPEN	 = TCPF_ESTABLISHED,
-	DCCPF_REQUESTING = TCPF_SYN_SENT,
-	DCCPF_LISTEN	 = TCPF_LISTEN,
-	DCCPF_RESPOND	 = TCPF_SYN_RECV,
-	DCCPF_CLOSING	 = TCPF_CLOSING,
-	DCCPF_TIME_WAIT	 = TCPF_TIME_WAIT,
-	DCCPF_CLOSED	 = TCPF_CLOSE,
-	DCCPF_PARTOPEN	 = (1 << DCCP_PARTOPEN),
+	DCCPF_OPEN	      = TCPF_ESTABLISHED,
+	DCCPF_REQUESTING      = TCPF_SYN_SENT,
+	DCCPF_LISTEN	      = TCPF_LISTEN,
+	DCCPF_RESPOND	      = TCPF_SYN_RECV,
+	DCCPF_ACTIVE_CLOSEREQ = TCPF_FIN_WAIT1,
+	DCCPF_CLOSING	      = TCPF_CLOSING,
+	DCCPF_TIME_WAIT	      = TCPF_TIME_WAIT,
+	DCCPF_CLOSED	      = TCPF_CLOSE,
+	DCCPF_PARTOPEN	      = (1 << DCCP_PARTOPEN),
 };
 
 static inline struct dccp_hdr *dccp_hdr(const struct sk_buff *skb)
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -60,8 +60,7 @@ void dccp_set_state(struct sock *sk, con
 {
 	const int oldstate = sk->sk_state;
 
-	dccp_pr_debug("%s(%p) %-10.10s -> %s\n",
-		      dccp_role(sk), sk,
+	dccp_pr_debug("%s(%p)  %s  -->  %s\n", dccp_role(sk), sk,
 		      dccp_state_name(oldstate), dccp_state_name(state));
 	WARN_ON(state = oldstate);
 
@@ -134,14 +133,17 @@ EXPORT_SYMBOL_GPL(dccp_packet_name);
 const char *dccp_state_name(const int state)
 {
 	static char *dccp_state_names[] = {
-	[DCCP_OPEN]	  = "OPEN",
-	[DCCP_REQUESTING] = "REQUESTING",
-	[DCCP_PARTOPEN]	  = "PARTOPEN",
-	[DCCP_LISTEN]	  = "LISTEN",
-	[DCCP_RESPOND]	  = "RESPOND",
-	[DCCP_CLOSING]	  = "CLOSING",
-	[DCCP_TIME_WAIT]  = "TIME_WAIT",
-	[DCCP_CLOSED]	  = "CLOSED",
+	[DCCP_OPEN]		= "OPEN",
+	[DCCP_REQUESTING]	= "REQUESTING",
+	[DCCP_PARTOPEN]		= "PARTOPEN",
+	[DCCP_LISTEN]		= "LISTEN",
+	[DCCP_RESPOND]		= "RESPOND",
+	[DCCP_CLOSING]		= "CLOSING",
+	[DCCP_ACTIVE_CLOSEREQ]	= "CLOSEREQ",
+	[DCCP_PASSIVE_CLOSE]	= "PASSIVE_CLOSE",
+	[DCCP_PASSIVE_CLOSEREQ]	= "PASSIVE_CLOSEREQ",
+	[DCCP_TIME_WAIT]	= "TIME_WAIT",
+	[DCCP_CLOSED]		= "CLOSED",
 	};
 
 	if (state >= DCCP_MAX_STATES)
