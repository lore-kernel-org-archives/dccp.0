From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 16 Apr 2008 07:43:25 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080416074325.GC4278@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Tomasz Grobelny:
| Dnia Tuesday 15 of April 2008, Gerrit Renker napisa?:
| > | > @@ -501,6 +519,8 @@ struct dccp_sock {
| > | >  	struct ccid			*dccps_hc_rx_ccid;
| > | >  	struct ccid			*dccps_hc_tx_ccid;
| > | >  	struct dccp_options_received	dccps_options_received;
| > | > +	__u8				dccps_qpolicy;
| > | > +	__u32				dccps_tx_qlen;
| > | >  	enum dccp_role			dccps_role:2;
| > | >  	__u8				dccps_hc_rx_insert_options:1;
| > | >  	__u8				dccps_hc_tx_insert_options:1;
| > |
| > | I know that currently none of the policies has any per-socket data. B=
ut
| > | if it had were should it go?
| >
| > I can't see anything wrong with putting everything into dccp_sock. To d=
o it
| > well, we could consider inserting documentation such as "this section is
| > only for queueing policies" (as is done very well for struct tcp_sock).
| >
| Let me remind you your comment made on 18/03/2008 on dccp ml to my first =

| patch:
|  --- START ---=20
| @@ -545,6 +549,8 @@ struct dccp_sock {
| =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0dccps_hc_tx_insert_options:1;
| =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0dccps_server_timewait:1;
| =A0 =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 dccps_xmit_=
timer;
| + =A0 =A0 =A0 struct queuing_policy =A0 =A0=A0=A0=A0=A0=A0=A0=A0*dccps_po=
licy;
| + =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0*dccps_policy_data;
| =A0};
|=20
| I think this should be just one field for the policy, and the
| policy_data can be an internal field of `struct queueing_policy'
| (compare with struct ackvec or struct ccid).
|  --- END ---=20
|=20
Hm, even after reading it again I still find that I don't like void* fields=
. It
may be a personal thing, but I think using void* as part of a field is bad =
(and
this was in an even earlier comment).

I think I understand your approach better now, after going through the
patches again.


| Ok, you are right. If before DCCP_LISTENING there is always DCCP_CLOSED t=
hen=20
| there is no need to allow changing qpolicy in DCCP_LISTENING state.
|=20
Yes, that's right -- the initial state is always DCCP_CLOSED, set in
dccp_init_sock().


The University of Aberdeen is a charity registered in Scotland, No SC013683.

