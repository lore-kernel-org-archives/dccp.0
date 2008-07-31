From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 31 Jul 2008 03:29:56 +0000
Subject: Re: [PATCH] DCCP: Fix to handle invalid packets in REQUEST state
Message-Id: <489131B4.3090505@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <488FF324.6050706@cn.fujitsu.com>
In-Reply-To: <488FF324.6050706@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> Wei,
>
> thank you for reporting this. There is a differentiation here.
>
>  =20
>> This patch fix two problem in REQUEST state while received invalid packe=
ts.
>>
>> 1. If invalid Dccp-DataAck packets is received in the REQUEST state, the=
 =20
>> socket just send back Dccp-Rest with invalid packet error, but the =20
>> socket is not reset, Dccp-Request will be continue retranmitted. The =20
>> procedure is like this:
>>
>> Endpoint A                   Endpint B
>>         <-----------------  Request
>> DataAck  ----------------->          <-----------------  Reset (invalid =

>> packet)
>>         <-----------------  Request (retranmit)
>>
>>    =20
> This is not a bug but as far as I know correct behaviour. The DataAck
> could be from a previous incarnation of the same connection, or it could
> be an erratic packet. RFC 4340, 5.6 says about this error code
>  "Packet Error"
>    A valid packet arrived with unexpected type.  For example, a
>    DCCP-Data packet with valid header checksum and sequence numbers
>    arrived at a connection in the REQUEST state.=20
>
> The client keeps on retransmitting the Request since this is a
> requirement from 8.1.3; the number of retransmissions is limited
> by net.dccp.default.request_retries.
>
> Hence this case is in principle correct.
>  =20

This case is correct. 7.5.6 has an final example demonstrates recovery
from a half-open connection. The difference is that Dccp-Sync is
received in REQUEST state.
This make me confusion. When to sent reset not close the connection,
when to sent reset and need close the connection?

>> 2. If sequence-invalid Dccp-Response is received in the REQUEST state,  =

>> kernel will panic. This is because that after send reset when received  =

>> sequence-invalid Dccp-Response, the state of socket not be changed. The =
=20
>> procedure is like this:
>>
>> Endpoint A                   Endpint B
>>         <-----------------  Request
>> Response ----------------->  (sequence-invalid)
>>         <-----------------  Reset (invalid packet)
>> Response ----------------->  kernel panic
>>
>> Pid: 0, comm: swapper Not tainted (2.6.26 #1)
>> EIP: 0060:[<c05b426d>] EFLAGS: 00010282 CPU: 0
>> EIP is at skb_release_all+0x6/0x7e
>> EAX: 00000000 EBX: 00000000 ECX: 00000046 EDX: c4fdd000
>> ESI: c79aad80 EDI: c4fdd000 EBP: c077ee0c ESP: c077ee08
>> DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
>> Process swapper (pid: 0, ti=C077e000 task=C0700340 task.ti=C0734000)
>> Stack: 00000000 c077ee18 c05b3bf3 c79a9234 c077ee58 c8ab1db5 c79aad80 c4=
fdd000
>>       02000015 c79aada0 00000c3c 00000854 c79aad80 c077ee50 c04260db c8a=
c176e
>>       0059b20e c4fdd000 c79aad80 c4fdd000 c077ee78 c8ac06e3 0000001c c79=
a9234
>> Call Trace:
>> [<c05b3bf3>] ? __kfree_skb+0xb/0x66
>>    =20
> <snip>
> This is clearly a bug. From your analysis above and from looking at the c=
ode
> the cause is in all likelihood:
>  1. sequence-invalid Response arrives;
>  2. retransmit timer is stopped and sk->sk_send_head is freed;
>  3. Reset (Packet Error) is sent as per the above diagram;
>  4. Next Response (valid or invalid) arrives
>  5. dccp_rcv_request_sent_state_process tries to __kfree_skb() the
>     sk_send_head (which had already been freed in (2))
>     =3D> panic
>
> In your approach the socket is closed for each error case. This seems to
> work, but there is a problem with it.=20
>
> First, invalid or unexpected packets may arrive (as in the first
> scenario). It is even possible that for example a DataAck stems from a
> previous incarnation of the same connection. Closing the socket here
> will kill the new connection.
>
> Secondly, it also opens the door to an easy denial-of-service attack:
> all an attacker needs to do is to send an unexpected packet type to the
> client in state REQUEST, whereupon the client closes its socket.
>  =20

The problem still exists if we not close the client's socket. See the
following:

The Client                        The Server
                                  (OPEN)
Request        ---------------->
               <---------------   Sync, DataAck etc.
Reset          ---------------->  enter TIMEWAIT state (8.5, Step 9)
Request        ----------------> =20
               <----------------  Reset (no connection)


So I think if you'd like to retransmit Request and let Server to send
Response, you should change the server not to enter TIMEWAIT state, just
enter CLOSED state, this break the 8.5, Step 9.

> The `unable_to_proceed' jump label was intended for the following
> (single) purpose: if feature negotiation fails between endpoints (e.g.
> if a CCID-3 only sender tries to connect to a CCID-2 only receiver).=20
>
> Thus, I would like to suggest a different strategy: rather than closing
> the socket whenever a (valid or invalid) packet is received in the
> client-state REQUEST(ING), to move the chunk of code which
>  * stops the retransmit timer for the DCCP-Request and
>  * frees the sk_send_head containing the original skb
> further below, after the error checking has been done.
>
> This will ensure that this code is only executed when a valid Response
> arrives. If no valid Response arrives within the time budget set by the
> request_retries, the retransmit timer and send_head will eventually=20
> be cleared via the timer code (dccp_write_err()).
>
> I attach a sketch which I think will fix the bug. Could you give this a
> try please? During the next two weeks it will be difficult for me to=20
> do actual testing (writing this while travelling), but I will do my
> best to respond.
>
>  =20

