From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 29 Sep 2007 16:44:53 +0000
Subject: [PATCH 3/3]: Convert Reset code into socket error number
Message-Id: <200709291744.53552@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

[DCCP]: Convert Reset code into socket error number

This adds support for converting the 11 currently defined Reset codes into =
system
error numbers, which are stored in sk_err for further interpretation.

This makes the externally visible API behaviour similar to TCP, since a cli=
ent
connecting to a non-existing port will experience ECONNREFUSED.
=20
 * Code 0, Unspecified, is interpreted as non-error (0);
 * Code 1, Closed (normal termination), also maps into 0;
 * Code 2, Aborted, maps into "Connection reset by peer" (ECONNRESET);
 * Code 3, No Connection and
   Code 7, Connection Refused, map into "Connection refused" (ECONNREFUSED);
 * Code 4, Packet Error, maps into "No message of desired type" (ENOMSG);
 * Code 5, Option Error, maps into "Illegal byte sequence" (EILSEQ);
 * Code 6, Mandatory Error, maps into "Operation not supported on transport=
 endpoint" (EOPNOTSUPP);
 * Code 8, Bad Service Code, maps into "Invalid request code" (EBADRQC);
 * Code 9, Too Busy, maps into "Too many users" (EUSERS);
 * Code 10, Bad Init Cookie, maps into "Invalid request descriptor" (EBADR);
 * Code 11, Aggression Penalty, maps into "Quota exceeded" (EDQUOT)
   which makes sense in terms of using more than the `fair share' of bandwi=
dth.

The patch was found to solve the problem reported by R=C3=A9mi Denis-Courmo=
nt - many thanks.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>  =20
---
 net/dccp/input.c |   48 +++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 39 insertions(+), 9 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -55,6 +55,42 @@ static void dccp_rcv_closereq(struct soc
 	dccp_send_close(sk, 0);
 }
=20
+static u8 dccp_reset_code_convert(const u8 code)
+{
+	const u8 error_code[] =3D {
+	[DCCP_RESET_CODE_CLOSED]	     =3D 0,	/* normal termination */
+	[DCCP_RESET_CODE_UNSPECIFIED]	     =3D 0,	/* nothing known */
+	[DCCP_RESET_CODE_ABORTED]	     =3D ECONNRESET,
+
+	[DCCP_RESET_CODE_NO_CONNECTION]	     =3D ECONNREFUSED,
+	[DCCP_RESET_CODE_CONNECTION_REFUSED] =3D ECONNREFUSED,
+	[DCCP_RESET_CODE_TOO_BUSY]	     =3D EUSERS,
+	[DCCP_RESET_CODE_AGGRESSION_PENALTY] =3D EDQUOT,
+
+	[DCCP_RESET_CODE_PACKET_ERROR]	     =3D ENOMSG,
+	[DCCP_RESET_CODE_BAD_INIT_COOKIE]    =3D EBADR,
+	[DCCP_RESET_CODE_BAD_SERVICE_CODE]   =3D EBADRQC,
+	[DCCP_RESET_CODE_OPTION_ERROR]	     =3D EILSEQ,
+	[DCCP_RESET_CODE_MANDATORY_ERROR]    =3D EOPNOTSUPP,
+	};
+
+	return code <=3D DCCP_RESET_CODE_AGGRESSION_PENALTY? error_code[code] : 0;
+}
+
+static void dccp_rcv_reset(struct sock *sk, struct sk_buff *skb)
+{
+	u8 err =3D dccp_reset_code_convert(dccp_hdr_reset(skb)->dccph_reset_code);
+
+	sk->sk_err =3D err;
+
+	/* Queue the equivalent of TCP fin so that dccp_recvmsg exits the loop */
+	dccp_fin(sk, skb);
+
+	if (err && !sock_flag(sk, SOCK_DEAD))
+		sk_wake_async(sk, 0, POLL_ERR);
+	dccp_time_wait(sk, DCCP_TIME_WAIT, 0);
+}
+
 static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp =3D dccp_sk(sk);
@@ -175,9 +211,8 @@ static int __dccp_rcv_established(struct
 		 *		S.state :=3D TIMEWAIT
 		 *		Set TIMEWAIT timer
 		 *		Drop packet and return
-		*/
-		dccp_fin(sk, skb);
-		dccp_time_wait(sk, DCCP_TIME_WAIT, 0);
+		 */
+		dccp_rcv_reset(sk, skb);
 		return 0;
 	case DCCP_PKT_CLOSEREQ:
 		dccp_rcv_closereq(sk, skb);
@@ -505,12 +540,7 @@ int dccp_rcv_state_process(struct sock *
 	 *		Drop packet and return
 	*/
 	if (dh->dccph_type =3D DCCP_PKT_RESET) {
-		/*
-		 * Queue the equivalent of TCP fin so that dccp_recvmsg
-		 * exits the loop
-		 */
-		dccp_fin(sk, skb);
-		dccp_time_wait(sk, DCCP_TIME_WAIT, 0);
+		dccp_rcv_reset(sk, skb);
 		return 0;
 		/*
 		 *   Step 7: Check for unexpected packet types
