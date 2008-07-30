From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 30 Jul 2008 16:51:41 +0000
Subject: Re: [PATCH] DCCP: Fix to handle invalid packets in REQUEST state
Message-Id: <20080730165141.GA10381@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
List-Id: <dccp.vger.kernel.org>
References: <488FF324.6050706@cn.fujitsu.com>
In-Reply-To: <488FF324.6050706@cn.fujitsu.com>
To: dccp@vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Wei,

thank you for reporting this. There is a differentiation here.

> This patch fix two problem in REQUEST state while received invalid packets.
>
> 1. If invalid Dccp-DataAck packets is received in the REQUEST state, the  
> socket just send back Dccp-Rest with invalid packet error, but the  
> socket is not reset, Dccp-Request will be continue retranmitted. The  
> procedure is like this:
>
> Endpoint A                   Endpint B
>         <-----------------  Request
> DataAck  ----------------->          <-----------------  Reset (invalid 
> packet)
>         <-----------------  Request (retranmit)
>
This is not a bug but as far as I know correct behaviour. The DataAck
could be from a previous incarnation of the same connection, or it could
be an erratic packet. RFC 4340, 5.6 says about this error code
 "Packet Error"
   A valid packet arrived with unexpected type.  For example, a
   DCCP-Data packet with valid header checksum and sequence numbers
   arrived at a connection in the REQUEST state. 

The client keeps on retransmitting the Request since this is a
requirement from 8.1.3; the number of retransmissions is limited
by net.dccp.default.request_retries.

Hence this case is in principle correct.

> 2. If sequence-invalid Dccp-Response is received in the REQUEST state,  
> kernel will panic. This is because that after send reset when received  
> sequence-invalid Dccp-Response, the state of socket not be changed. The  
> procedure is like this:
>
> Endpoint A                   Endpint B
>         <-----------------  Request
> Response ----------------->  (sequence-invalid)
>         <-----------------  Reset (invalid packet)
> Response ----------------->  kernel panic
>
> Pid: 0, comm: swapper Not tainted (2.6.26 #1)
> EIP: 0060:[<c05b426d>] EFLAGS: 00010282 CPU: 0
> EIP is at skb_release_all+0x6/0x7e
> EAX: 00000000 EBX: 00000000 ECX: 00000046 EDX: c4fdd000
> ESI: c79aad80 EDI: c4fdd000 EBP: c077ee0c ESP: c077ee08
> DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=c077e000 task=c0700340 task.ti=c0734000)
> Stack: 00000000 c077ee18 c05b3bf3 c79a9234 c077ee58 c8ab1db5 c79aad80 c4fdd000
>       02000015 c79aada0 00000c3c 00000854 c79aad80 c077ee50 c04260db c8ac176e
>       0059b20e c4fdd000 c79aad80 c4fdd000 c077ee78 c8ac06e3 0000001c c79a9234
> Call Trace:
> [<c05b3bf3>] ? __kfree_skb+0xb/0x66
<snip>
This is clearly a bug. From your analysis above and from looking at the code
the cause is in all likelihood:
 1. sequence-invalid Response arrives;
 2. retransmit timer is stopped and sk->sk_send_head is freed;
 3. Reset (Packet Error) is sent as per the above diagram;
 4. Next Response (valid or invalid) arrives
 5. dccp_rcv_request_sent_state_process tries to __kfree_skb() the
    sk_send_head (which had already been freed in (2))
    ==> panic

In your approach the socket is closed for each error case. This seems to
work, but there is a problem with it. 

First, invalid or unexpected packets may arrive (as in the first
scenario). It is even possible that for example a DataAck stems from a
previous incarnation of the same connection. Closing the socket here
will kill the new connection.

Secondly, it also opens the door to an easy denial-of-service attack:
all an attacker needs to do is to send an unexpected packet type to the
client in state REQUEST, whereupon the client closes its socket.

The `unable_to_proceed' jump label was intended for the following
(single) purpose: if feature negotiation fails between endpoints (e.g.
if a CCID-3 only sender tries to connect to a CCID-2 only receiver). 

Thus, I would like to suggest a different strategy: rather than closing
the socket whenever a (valid or invalid) packet is received in the
client-state REQUEST(ING), to move the chunk of code which
 * stops the retransmit timer for the DCCP-Request and
 * frees the sk_send_head containing the original skb
further below, after the error checking has been done.

This will ensure that this code is only executed when a valid Response
arrives. If no valid Response arrives within the time budget set by the
request_retries, the retransmit timer and send_head will eventually 
be cleared via the timer code (dccp_write_err()).

I attach a sketch which I think will fix the bug. Could you give this a
try please? During the next two weeks it will be difficult for me to 
do actual testing (writing this while travelling), but I will do my
best to respond.



--wac7ysb48OaltWcw
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="sketch_for_retransmitted_request_bug.diff"

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -404,12 +404,6 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		struct dccp_sock *dp = dccp_sk(sk);
 		long tstamp = dccp_timestamp();
 
-		/* Stop the REQUEST timer */
-		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
-		WARN_ON(sk->sk_send_head == NULL);
-		__kfree_skb(sk->sk_send_head);
-		sk->sk_send_head = NULL;
-
 		if (!between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
 			       dp->dccps_awl, dp->dccps_awh)) {
 			dccp_pr_debug("invalid ackno: S.AWL=%llu, "
@@ -428,6 +422,12 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		if (dccp_parse_options(sk, NULL, skb))
 			return 1;
 
+		/* Stop the REQUEST timer */
+		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
+		WARN_ON(sk->sk_send_head == NULL);
+		__kfree_skb(sk->sk_send_head);
+		sk->sk_send_head = NULL;
+
 		/* Obtain usec RTT sample from SYN exchange (used by CCID 3) */
 		if (likely(dp->dccps_options_received.dccpor_timestamp_echo))
 			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * (tstamp -

--wac7ysb48OaltWcw--
