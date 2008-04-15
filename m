From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 15 Apr 2008 15:14:03 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080415151403.GA20735@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| >   * makes tx_qlen a socket member of dccp_sock (there was a bug in the
| >     implementation -- tx_qlen was shared by all sockets using the same
| > policy); 
| Haven't tested it thoroughly but it shouldn't be so. After all qpol_txqlen was 
| part of struct dccp_qpolicy which was in turn part of dccp_sock.
| 
I have to apologise here -- this was my oversight. The bug I assumed to be there 
does not exist, since the tx_qlen was indeed part of the socket. Sorry.


| > +/*
| > + * Wrappers for methods provided by policy currently in use
| > + */
| > +void qpolicy_push(struct sock *sk, struct sk_buff *skb, struct msghdr
| > *msg) +{
| > +	struct dccp_packet_info *dcp = NULL;
| > +
| > +	if (msg->msg_control != NULL && msg->msg_controllen = sizeof(*dcp))
| > +		dcp = (struct dccp_packet_info *)msg->msg_control;
| > +
| > +	qpol_table[dccp_sk(sk)->dccps_qpolicy].push(sk, skb, dcp);
| > +}
| > +
| What happens if application is compiled with dccp_packet_info containing only 
| one field (priority) and kernel containing two fields (for example priority 
| and later added expiry time)? Wouldn't that implementation make extensions to 
| dccp_packet_info impossible?
Had not looked at it from this point of view. So you are suggesting

	if (msg->msg_control != NULL && msg->msg_controllen >= sizeof(*dcp))
		dcp = (struct dccp_packet_info *)msg->msg_control;

instead? Agreed, point #1 to change in the patch.


| 
| > @@ -501,6 +519,8 @@ struct dccp_sock {
| >  	struct ccid			*dccps_hc_rx_ccid;
| >  	struct ccid			*dccps_hc_tx_ccid;
| >  	struct dccp_options_received	dccps_options_received;
| > +	__u8				dccps_qpolicy;
| > +	__u32				dccps_tx_qlen;
| >  	enum dccp_role			dccps_role:2;
| >  	__u8				dccps_hc_rx_insert_options:1;
| >  	__u8				dccps_hc_tx_insert_options:1;
| I know that currently none of the policies has any per-socket data. But if it 
| had were should it go?
| 
I can't see anything wrong with putting everything into dccp_sock. To do it well, 
we could consider inserting documentation such as "this section is only for
queueing policies" (as is done very well for struct tcp_sock).

I see several advantages of this:
 * by just storing the u8 of the policy ID, the socket as a whole gets smaller,
 * when not using nested structs, the elements can be optimised for minimal space,
 * the internals of the function pointer table can be hidden,
 * the socket carries the same information as is passed on via socket options,
   which simplifies querying.


| > +	case DCCP_SOCKOPT_QPOLICY_ID:
| > +		if (sk->sk_state != DCCP_CLOSED)
| > +			err = -EISCONN;
| What about DCCP_LISTENING state?
| 
There is a problem with allowing this, considering for example:
 * socket is created, and listen() is called,
 * socket enters with default policy,
 * now user decides to change policy from default ("simple") to "prio",
 * before he can do that, the first packet arrives on the incoming
   queue, policy is inherited to child socket,
 * so this connection ends up with "simple" policy instead of "prio".


| > +DCCP_SOCKOPT_QPOLICY_TXQLEN sets the maximum TX queue length. This is
| > relevant only for +those TX dequeueing policies that honour this upper
| > bound (currently only the +simple/default policy does this). This socket
| > option overrides the default value +of the sysctl
| > /proc/sys/net/dccp/default/tx_qlen.
| >
| In my implementation prio policy did honour DCCP_SOCKOPT_QPOLICY_TXQLEN 
| setting. At least it was meant to do so.
| 
The documentation certainly needs more work, I just sketched something
but it is not very good. So this is point #2 which needs to change.

Ideally, it would have a little description of what each policy does and
for which use case it is best suited.

Please take your time and check through the other parts of the patch as
well. I would like to accumulate the issues and then address each of the
points. And also, do some testing.I haven't had time to write test code for
prio policy -- is there something in your SVN repository?

Gerrit


The University of Aberdeen is a charity registered in Scotland, No SC013683.

