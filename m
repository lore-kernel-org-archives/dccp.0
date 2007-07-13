From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Jul 2007 15:23:17 +0000
Subject: [PATCH 2/2]: Add support for abortive release
Message-Id: <200707131623.17346@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Add support for abortive release

This continues from the previous patch and adds support for actively aborting
a DCCP connection, using a Reset Code 2, "Aborted" to inform the peer of an
abortive release.

I have tried this in various client/server settings and it works as expected.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/proto.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -282,6 +282,12 @@ static inline int dccp_listen_start(stru
 	return inet_csk_listen_start(sk, backlog);
 }
 
+static inline int dccp_need_reset(int state)
+{
+	return state != DCCP_CLOSED && state != DCCP_LISTEN &&
+	       state != DCCP_REQUESTING;
+}
+
 int dccp_disconnect(struct sock *sk, int flags)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -292,10 +298,15 @@ int dccp_disconnect(struct sock *sk, int
 	if (old_state != DCCP_CLOSED)
 		dccp_set_state(sk, DCCP_CLOSED);
 
-	/* ABORT function of RFC793 */
+	/*
+	 * This corresponds to the ABORT function of RFC793, sec. 3.8
+	 * TCP uses a RST segment, DCCP a Reset packet with Code 2, "Aborted".
+	 */
 	if (old_state = DCCP_LISTEN) {
 		inet_csk_listen_stop(sk);
-	/* FIXME: do the active reset thing */
+	} else if (dccp_need_reset(old_state)) {
+		dccp_send_reset(sk, DCCP_RESET_CODE_ABORTED);
+		sk->sk_err = ECONNRESET;
 	} else if (old_state = DCCP_REQUESTING)
 		sk->sk_err = ECONNRESET;
 
