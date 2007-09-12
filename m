From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Sep 2007 14:35:20 +0000
Subject: [PATCH 4/5]: DCCP's passive close needs to match TCP's half-close
Message-Id: <200709121535.20408@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: DCCP's passive close needs to match TCP's half-close

This fixes a problem of integrating the new auxiliary states PASSIVE_1/2 with the
inet_xxx infrastructure. 

The problem appears on the listening side and is that
 * a Close may have been received on the socket while it is still in the accept queue
   of the master/listening socket;
 * hence when it is taken out of the queue by inet_accept(), the state of the socket
   is PASSIVE_1 (whose value is greater than all registered TCP states);
 * this triggers the following warning in inet_accept():
  
   Sep 10 16:52:27 kernel: KERNEL: \
	assertion ((1 << sk2->sk_state) & (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_CLOSE))\
	failed at /usr/src/main_davem-2.6/net/ipv4/af_inet.c (646)

The fix consists mapping PASSIVE_1 into TCPF_CLOSE_WAIT, which is possible since
there is no other mapping from a DCCP state into it. Incidentally, the `semantics'
of that state are also similar: in TCP's CLOSE_WAIT, a user confirmation to close
up the socket is needed - and the same (calling close/exit) situation arises here.

For a server deciding to hold TIMEWAIT state there is no such problem, since
DCCP_SOCKOPT_SERVER_TIMEWAIT can not be set on a listening socket, it is by default off
and not inherited to child sockets.

Lastly, for PASSIVE_2 the situation is simpler, since this is a client-only state. 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -249,14 +249,14 @@ enum dccp_state {
 	 * CLOSING, corresponds to (b) above) are used.
 	 */
 	DCCP_CLOSEREQ	= TCP_FIN_WAIT1,
+	DCCP_PASSIVE_1	= TCP_CLOSE_WAIT,	/* any node receiving a Close */
 	DCCP_CLOSING	= TCP_CLOSING,
 	DCCP_TIME_WAIT	= TCP_TIME_WAIT,
 	DCCP_CLOSED	= TCP_CLOSE,
 	/* Everything below here is specific to DCCP only */
 	DCCP_INTRINSICS = TCP_MAX_STATES,
 	DCCP_PARTOPEN,
-	DCCP_PASSIVE_1,		/* any node receiving a Close  */
-	DCCP_PASSIVE_2,		/* client receiving a CloseReq */
+	DCCP_PASSIVE_2,				/* client receiving CloseReq  */
 	DCCP_MAX_STATES
 };
 
