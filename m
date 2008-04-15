From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 15 Apr 2008 20:04:07 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080415200407.GD5025@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Em Tue, Apr 15, 2008 at 09:38:40PM +0200, Tomasz Grobelny escreveu:
> Dnia Tuesday 15 of April 2008, Gerrit Renker napisał:
> > | > @@ -501,6 +519,8 @@ struct dccp_sock {
> > | >  	struct ccid			*dccps_hc_rx_ccid;
> > | >  	struct ccid			*dccps_hc_tx_ccid;
> > | >  	struct dccp_options_received	dccps_options_received;
> > | > +	__u8				dccps_qpolicy;
> > | > +	__u32				dccps_tx_qlen;
> > | >  	enum dccp_role			dccps_role:2;
> > | >  	__u8				dccps_hc_rx_insert_options:1;
> > | >  	__u8				dccps_hc_tx_insert_options:1;
> > |
> > | I know that currently none of the policies has any per-socket data. But
> > | if it had were should it go?
> >
> > I can't see anything wrong with putting everything into dccp_sock. To do it
> > well, we could consider inserting documentation such as "this section is
> > only for queueing policies" (as is done very well for struct tcp_sock).
> >
> Let me remind you your comment made on 18/03/2008 on dccp ml to my first 
> patch:
>  --- START --- 
> @@ -545,6 +549,8 @@ struct dccp_sock {
>         __u8                            dccps_hc_tx_insert_options:1;
>         __u8                            dccps_server_timewait:1;
>         struct timer_list               dccps_xmit_timer;
> +       struct queuing_policy           *dccps_policy;
> +       void                            *dccps_policy_data;
>  };
> 
> I think this should be just one field for the policy, and the
> policy_data can be an internal field of `struct queueing_policy'
> (compare with struct ackvec or struct ccid).
>  --- END --- 
> 
> > I see several advantages of this:
> >  * by just storing the u8 of the policy ID, the socket as a whole gets
> > smaller,
> >  * the internals of the function pointer table can be hidden,
> > 
> That's ok with me. 
> 
> > * when not using nested structs, the elements can be optimised for 
> > minimal space,
> I have nothing against it. In fact that's what I did in the first try.
> 
> > | > +	case DCCP_SOCKOPT_QPOLICY_ID:
> > | > +		if (sk->sk_state != DCCP_CLOSED)
> > | > +			err = -EISCONN;
> > |
> > | What about DCCP_LISTENING state?
> >
> > There is a problem with allowing this, considering for example:
> > (...)
> Ok, you are right. If before DCCP_LISTENING there is always DCCP_CLOSED then 
> there is no need to allow changing qpolicy in DCCP_LISTENING state.
> 
> > Please take your time and check through the other parts of the patch as
> > well. I would like to accumulate the issues and then address each of the
> If I didn't mention some parts of the patch you can assume that I'm ok with 
> them.
> 
> > points. And also, do some testing.I haven't had time to write test code for
> > prio policy -- is there something in your SVN repository?
> >
> Have a look at http://dccp.one.pl/svn/userspace/test/ And I'll also do some 
> testing of your patch.
> 
> One more question (probably more for Arnaldo): is there any timeframe to push 
> changes from test tree upstream?

Not at this moment, I'm not managing to dedicate time for another round
of reviewing of what is in Gerrit's tree :-(

- Arnaldo
