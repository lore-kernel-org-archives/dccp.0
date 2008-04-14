From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 14 Apr 2008 23:45:05 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804150145.05571.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 14 of April 2008, Gerrit Renker napisa=B3:
> [DCCP] [RFC]: Reworked queueing policy patch set
>
> This is a re-worked version of Tomasz's priority-queueing patch set for
> DCCP. The essential internals of his patch set have been left untouched,
> in particular the prio/simple algorithms are the same as before.
>
> The changes for which I am asking for comments are:
>
>   Given that each file has less than 100 lines, it seemed better to put
> them all into one file and export the declarations in dccp.h, the result =
is
> now:
>
>   With less than 150 lines, there is still room for a few more policies.
>
For now the files are small but I would expect at least qpolicy_prio.c to g=
row=20
a little bit in the future. What comes to mind are get/setsockopts (for=20
example statistics about packets dropped by qpolicy), and per packet expiry=
=20
times. I didn't look how big the files are but wanted to have clear=20
separation between specific policies and common code. But if you think that=
=20
this organization is better I have no problem with it.

> 2. Let pop() return result
> --------------------------
>   * at least for the forseeable future, the underlying queue is
> sk_write_queue; * an skb can not be on two lists at the same time;
>   * thus skb_unlink will always be part of implementing pop();
>   * having pop() return the skb is more versatile (compare Assembler
> pop()).
>
That should be fine...

>   * makes tx_qlen a socket member of dccp_sock (there was a bug in the
>     implementation -- tx_qlen was shared by all sockets using the same
> policy);=20
Haven't tested it thoroughly but it shouldn't be so. After all qpol_txqlen =
was=20
part of struct dccp_qpolicy which was in turn part of dccp_sock.

> +/*
> + * Wrappers for methods provided by policy currently in use
> + */
> +void qpolicy_push(struct sock *sk, struct sk_buff *skb, struct msghdr
> *msg) +{
> +	struct dccp_packet_info *dcp =3D NULL;
> +
> +	if (msg->msg_control !=3D NULL && msg->msg_controllen =3D sizeof(*dcp))
> +		dcp =3D (struct dccp_packet_info *)msg->msg_control;
> +
> +	qpol_table[dccp_sk(sk)->dccps_qpolicy].push(sk, skb, dcp);
> +}
> +
What happens if application is compiled with dccp_packet_info containing on=
ly=20
one field (priority) and kernel containing two fields (for example priority=
=20
and later added expiry time)? Wouldn't that implementation make extensions =
to=20
dccp_packet_info impossible?

> @@ -501,6 +519,8 @@ struct dccp_sock {
>  	struct ccid			*dccps_hc_rx_ccid;
>  	struct ccid			*dccps_hc_tx_ccid;
>  	struct dccp_options_received	dccps_options_received;
> +	__u8				dccps_qpolicy;
> +	__u32				dccps_tx_qlen;
>  	enum dccp_role			dccps_role:2;
>  	__u8				dccps_hc_rx_insert_options:1;
>  	__u8				dccps_hc_tx_insert_options:1;
I know that currently none of the policies has any per-socket data. But if =
it=20
had were should it go?

> +	case DCCP_SOCKOPT_QPOLICY_ID:
> +		if (sk->sk_state !=3D DCCP_CLOSED)
> +			err =3D -EISCONN;
What about DCCP_LISTENING state?

> --- a/Documentation/networking/dccp.txt
> +++ b/Documentation/networking/dccp.txt
> @@ -45,6 +45,17 @@ http://linux-net.osdl.org/index.php/DCCP
>
> +DCCP_SOCKOPT_QPOLICY_TXQLEN sets the maximum TX queue length. This is
> relevant only for +those TX dequeueing policies that honour this upper
> bound (currently only the +simple/default policy does this). This socket
> option overrides the default value +of the sysctl
> /proc/sys/net/dccp/default/tx_qlen.
>
In my implementation prio policy did honour DCCP_SOCKOPT_QPOLICY_TXQLEN=20
setting. At least it was meant to do so.

Having said "ok" here and there or nothing in other points I haven't tried =

applying this patch nor tested your rework.
--=20
Regards,
Tomasz Grobelny
