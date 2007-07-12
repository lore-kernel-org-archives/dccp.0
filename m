From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Jul 2007 14:23:39 +0000
Subject: [PATCH 3/10]: Dedicated auxiliary states to support passive-close
Message-Id: <200707121523.40095@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Dedicated auxiliary states to support passive-close

This adds two auxiliary states to deal with passive closes:
  * PASSIVE_1 (reached from OPEN via reception of Close) and
  * PASSIVE_2 (reached from OPEN via reception of CloseReq)
to the internal state machine.

The PASSIVE_1 and PASSIVE_2 states represent the two ways a passive-close
can happen in DCCP.  The addition of these states is not merely to
increase clarity. These states are required by the implementation to
allow a receiver to process unread data before acknowledging the received
connection-termination-request (i.e. the Close/CloseReq).

Fix:
----
 This patch uses the PASSIVE_1 and PASSIVE_2 states to explicitly refer to
 passive-closing states and to protect against external wipeout of internal
 receive queues. The macroscopic behaviour is compatible with RFC 4340, but
 without the auxiliary states, buggy, absurd and abnormal behaviour of the
 socket API will continue. Which is to say, without auxiliary states it does
 not work.

 As a consequence, the count of DCCP_STATE_MASK has been increased, to account
 for the number of new states. 


Implementation Note:
--------------------
 To keep compatibility with sk_stream_wait_connect():
 * DCCP_CLOSING continues to map into TCP_CLOSING (since this state can be
   either passive- or active-close)
 * DCCP_CLOSEREQ maps into TCP_FIN_WAIT1 (since it is always active-close)

 It is tempting to keep the clever merge of the CLOSEREQ and CLOSING states.
 However, with the number of possible state transitions, this would require:

 * quite a number of `if' statements to distinguish all predecessors of
   the CLOSING state (server/client, active/passive, server timewait yes/no);

 * two different branches from the CLOSING state:
   - to TIMEWAIT if it is not an active server-close without keeping timewait state
   - to CLOSED otherwise (and requiring to receive a Close instead of a Reset).
 
 In light of this, I think it is cleaner to implement separate CLOSEREQ and CLOSING
 states (this is done by the subsequent patches).

Further documentation is on http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/closing_states/


                    Why this is necessary [can be removed]
                    --------------------------------------

 The two states are not mentioned in the DCCP specification [RFC 4340, 8.4].
 In fact, RFC 4340 is silent about passive-close. In a nutshell, suppose that
 the CLOSE_WAIT and LAST_ACK states were removed from TCP, i.e. a FIN triggers
 direct transition from ESTABLISHED to CLOSED - similar problem. 
 The detailed account is as follows.

 The first problem lies in using inet_stream_connect():

 An absurd case arises if we let the protocol machinery, not the application,
 go through the states. If the protocol machinery allows to proceed to DCCP_CLOSED
 (which corresponds to TCP_CLOSE), connect() returns with -ECONNABORTED, even if
 there was data in the receive queue. 

 Therefore, if we want to keep the useful abstraction of inet_stream_connect(), we
 need to make sure that a passive close can not lead to DCCP_CLOSE via the protocol
 machinery alone. 

 The second problem is also related to entering DCCP_CLOSED too early: 

 Even if connect() were fixed, if a passive-close can directly trigger a state 
 transition from OPEN to DCCP_CLOSED, the receiver may not be able to read data
 from its input queue. The reason is that the input queue has already been wiped, 
 DCCP_CLOSED state has been entered, while the SOCK_DONE flag has not yet been set.
 Consequently, any subsequent call to dccp_recvmsg terminates in -ENOTCONN, 
 and this despite of a potentially full receive queue.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   22 +++++++++++++++++++++-
 net/dccp/proto.c     |    3 +++
 2 files changed, 24 insertions(+), 1 deletion(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -230,16 +230,35 @@ enum dccp_state {
 	DCCP_REQUESTING	= TCP_SYN_SENT,
 	DCCP_LISTEN	= TCP_LISTEN,
 	DCCP_RESPOND	= TCP_SYN_RECV,
+	/*
+	 *			Close states:
+	 *
+	 * CLOSEREQ is active-server close only.
+	 * CLOSING can have three different meanings [RFC 4340, 8.3]:
+	 *  a. Client has performed active-close, sent a Close to peer from
+	 *     state OPEN or PARTOPEN, waiting for the final Reset
+	 *     (in this case, SOCK_DONE = 1).
+	 *  b. Client performs passive-Close, by receiving an CloseReq in OPEN
+	 *     or PARTOPEN state. It sends a Close and waits for final Reset
+	 *     (in this case, SOCK_DONE = 0).
+	 *  c. Server decides to hold TIMEWAIT state & performs an active-close.
+	 * To avoid erasing receive queues too early, the transitional states
+	 * PASSIVE_1 (from OPEN => CLOSED) and PASSIVE_2 (from (PART)OPEN to
+	 * CLOSING, corresponds to (b) above) are used.
+	 */
+	DCCP_CLOSEREQ	= TCP_FIN_WAIT1,
 	DCCP_CLOSING	= TCP_CLOSING,
 	DCCP_TIME_WAIT	= TCP_TIME_WAIT,
 	DCCP_CLOSED	= TCP_CLOSE,
 	/* Everything below here is specific to DCCP only */
 	DCCP_INTRINSICS = TCP_MAX_STATES,
 	DCCP_PARTOPEN,
+	DCCP_PASSIVE_1,		/* any node receiving a Close  */
+	DCCP_PASSIVE_2,		/* client receiving a CloseReq */
 	DCCP_MAX_STATES
 };
 
-#define DCCP_STATE_MASK 0xf
+#define DCCP_STATE_MASK 0x1f
 #define DCCP_ACTION_FIN (1<<7)
 
 enum {
@@ -247,6 +266,7 @@ enum {
 	DCCPF_REQUESTING = TCPF_SYN_SENT,
 	DCCPF_LISTEN	 = TCPF_LISTEN,
 	DCCPF_RESPOND	 = TCPF_SYN_RECV,
+	DCCPF_CLOSEREQ	 = TCPF_FIN_WAIT1,
 	DCCPF_CLOSING	 = TCPF_CLOSING,
 	DCCPF_TIME_WAIT	 = TCPF_TIME_WAIT,
 	DCCPF_CLOSED	 = TCPF_CLOSE,
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -139,6 +139,9 @@ const char *dccp_state_name(const int st
 	[DCCP_LISTEN]	  = "LISTEN",
 	[DCCP_RESPOND]	  = "RESPOND",
 	[DCCP_CLOSING]	  = "CLOSING",
+	[DCCP_CLOSEREQ]	  = "CLOSEREQ",
+	[DCCP_PASSIVE_1]  = "PASSIVE_1",
+	[DCCP_PASSIVE_2]  = "PASSIVE_2",
 	[DCCP_TIME_WAIT]  = "TIME_WAIT",
 	[DCCP_CLOSED]	  = "CLOSED",
 	};
