From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 18 Aug 2008 05:02:51 +0000
Subject: Re: [PATCH] DCCP: Fix to handle invalid packets in REQUEST state
Message-Id: <48A9027B.6090109@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <488FF324.6050706@cn.fujitsu.com>
In-Reply-To: <488FF324.6050706@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> | >> 2. If sequence-invalid Dccp-Response is received in the REQUEST stat=
e, =20
> | >> kernel will panic. This is because that after send reset when receiv=
ed =20
> | >> sequence-invalid Dccp-Response, the state of socket not be changed. =
The =20
> | >> procedure is like this:
> | >>
> | >> Endpoint A                   Endpint B
> | >>         <-----------------  Request
> | >> Response ----------------->  (sequence-invalid)
> | >>         <-----------------  Reset (invalid packet)
> | >> Response ----------------->  kernel panic
> | >>
> | >> Pid: 0, comm: swapper Not tainted (2.6.26 #1)
> | >> EIP: 0060:[<c05b426d>] EFLAGS: 00010282 CPU: 0
> | >> EIP is at skb_release_all+0x6/0x7e
> | >> EAX: 00000000 EBX: 00000000 ECX: 00000046 EDX: c4fdd000
> | >> ESI: c79aad80 EDI: c4fdd000 EBP: c077ee0c ESP: c077ee08
> | >> DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> | >> Process swapper (pid: 0, ti=C077e000 task=C0700340 task.ti=C0734000)
> | >> Stack: 00000000 c077ee18 c05b3bf3 c79a9234 c077ee58 c8ab1db5 c79aad8=
0 c4fdd000
> | >>       02000015 c79aada0 00000c3c 00000854 c79aad80 c077ee50 c04260db=
 c8ac176e
> | >>       0059b20e c4fdd000 c79aad80 c4fdd000 c077ee78 c8ac06e3 0000001c=
 c79a9234
> | >> Call Trace:
> | >> [<c05b3bf3>] ? __kfree_skb+0xb/0x66
> | >>    =20
> | > <snip>
> | > This is clearly a bug. From your analysis above and from looking at t=
he code
> | > the cause is in all likelihood:
> | >  1. sequence-invalid Response arrives;
> | >  2. retransmit timer is stopped and sk->sk_send_head is freed;
> | >  3. Reset (Packet Error) is sent as per the above diagram;
> | >  4. Next Response (valid or invalid) arrives
> | >  5. dccp_rcv_request_sent_state_process tries to __kfree_skb() the
> | >     sk_send_head (which had already been freed in (2))
> | >     =3D> panic
> | >
> | > In your approach the socket is closed for each error case. This seems=
 to
> | > work, but there is a problem with it.=20
> | >
> | > First, invalid or unexpected packets may arrive (as in the first
> | > scenario). It is even possible that for example a DataAck stems from a
> | > previous incarnation of the same connection. Closing the socket here
> | > will kill the new connection.
> | >
> | > Secondly, it also opens the door to an easy denial-of-service attack:
> | > all an attacker needs to do is to send an unexpected packet type to t=
he
> | > client in state REQUEST, whereupon the client closes its socket.
> | >  =20
> |=20
> | The problem still exists if we not close the client's socket. See the
> | following:
> |=20
> | The Client                        The Server
> |                                   (OPEN)
> | Request        ---------------->
> |                <---------------   Sync, DataAck etc.
> | Reset          ---------------->  enter TIMEWAIT state (8.5, Step 9)
> | Request        ----------------> =20
> |                <----------------  Reset (no connection)
> |=20
> |=20
> | So I think if you'd like to retransmit Request and let Server to send
> | Response, you should change the server not to enter TIMEWAIT state, just
> | enter CLOSED state, this break the 8.5, Step 9.
> |=20
> >From looking through the code, a sequence-valide Reset packet will close
> the Client socket, via the following steps:
>  * packet is received via dccp_v{4,6}_do_rcv (dccp_child_process is not
>    relevant here, since we are interested in the client);
>  * since the state is not LISTEN, control proceeds to
>  * dccp_rcv_state_process and from there to
>  * dccp_rcv_reset, which
>    - sets the state to TIMEWAIT,
>    - shuts the socket for both sending and receiving,
>    - sets the SOCK_DEAD flag.
>
> In accordance with the note marked with the asterisk underneath the
> table in 7.5.3, no sequence number check is performed for the Reset
> packet, and an acknowledgment-window check is not applicable.
>
> >From this analysis, I think that the socket will be closed, with the
> client entering TIMEWAIT state as the last step.
>
> However, this is by just looking through, I have not tested if this
> holds in practice as expected (it should).
>
>  =20

Yes, it does, the last Reset (no connection) will cause client entering=20
TIMEWAIT state. Your patch is correct.

BTW: The other interesting thing is that maybe the following testcase=20
can be used for attack the sequence num:

The Client                        The Server
                                  (OPEN) (GSS=10, GSR=3D1)
Request        ---------------->
(SEQ=10000)
               <---------------   Sync
                                  (SEQ=11, ACK=10000)
Reset          ----------------> =20
(SEQ=10001, ACK=11)
               <---------------   Sync
                                  (SEQ=12, ACK=3D1)
DATA          ----------------> =20
(SEQ=3D2, ACK=12)
              <---------------   ACK
                 ..........


In this time, the client will know both the sever and the client's=20
sequence num, this maybe used for attack I think.
If it is a attack, so the best way to avoid this is not sent Dccp-Sync=20
after received the sequence-invalid reset.

Regards.

