From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 15 Apr 2008 19:38:40 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804152138.41077.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 15 of April 2008, Gerrit Renker napisa=B3:
> | > @@ -501,6 +519,8 @@ struct dccp_sock {
> | >  	struct ccid			*dccps_hc_rx_ccid;
> | >  	struct ccid			*dccps_hc_tx_ccid;
> | >  	struct dccp_options_received	dccps_options_received;
> | > +	__u8				dccps_qpolicy;
> | > +	__u32				dccps_tx_qlen;
> | >  	enum dccp_role			dccps_role:2;
> | >  	__u8				dccps_hc_rx_insert_options:1;
> | >  	__u8				dccps_hc_tx_insert_options:1;
> |
> | I know that currently none of the policies has any per-socket data. But
> | if it had were should it go?
>
> I can't see anything wrong with putting everything into dccp_sock. To do =
it
> well, we could consider inserting documentation such as "this section is
> only for queueing policies" (as is done very well for struct tcp_sock).
>
Let me remind you your comment made on 18/03/2008 on dccp ml to my first=20
patch:
 --- START ---=20
@@ -545,6 +549,8 @@ struct dccp_sock {
=A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0dccps_hc_tx_insert_options:1;
=A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0dccps_server_timewait:1;
=A0 =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 dccps_xmit_ti=
mer;
+ =A0 =A0 =A0 struct queuing_policy =A0 =A0=A0=A0=A0=A0=A0=A0=A0*dccps_poli=
cy;
+ =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*=
dccps_policy_data;
=A0};

I think this should be just one field for the policy, and the
policy_data can be an internal field of `struct queueing_policy'
(compare with struct ackvec or struct ccid).
 --- END ---=20

> I see several advantages of this:
>  * by just storing the u8 of the policy ID, the socket as a whole gets
> smaller,
>  * the internals of the function pointer table can be hidden,
>=20
That's ok with me.=20

> * when not using nested structs, the elements can be optimised for=20
> minimal space,
I have nothing against it. In fact that's what I did in the first try.

> | > +	case DCCP_SOCKOPT_QPOLICY_ID:
> | > +		if (sk->sk_state !=3D DCCP_CLOSED)
> | > +			err =3D -EISCONN;
> |
> | What about DCCP_LISTENING state?
>
> There is a problem with allowing this, considering for example:
> (...)
Ok, you are right. If before DCCP_LISTENING there is always DCCP_CLOSED the=
n=20
there is no need to allow changing qpolicy in DCCP_LISTENING state.

> Please take your time and check through the other parts of the patch as
> well. I would like to accumulate the issues and then address each of the
If I didn't mention some parts of the patch you can assume that I'm ok with=
=20
them.

> points. And also, do some testing.I haven't had time to write test code f=
or
> prio policy -- is there something in your SVN repository?
>
Have a look at http://dccp.one.pl/svn/userspace/test/ And I'll also do some=
=20
testing of your patch.

One more question (probably more for Arnaldo): is there any timeframe to pu=
sh=20
changes from test tree upstream?
--=20
Regards,
Tomasz Grobelny
