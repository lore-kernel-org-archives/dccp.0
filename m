From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 25 Apr 2008 20:40:24 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080425204024.GA16635@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Fri, Apr 25, 2008 at 09:33:11PM +0200, Tomasz Grobelny escreveu:
> Dnia Wednesday 23 of April 2008, David Miller napisa=C5=82:
> > From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> > Date: Tue, 22 Apr 2008 18:41:52 +0100
> >
> > > | If we iron this out we could finally return to the main subject of =
this
> > > | thread. That is Patch v2 by me and Gerrit...
> > > | --
> > >
> > > Fully agree - we just need to decide whether or not to use skb->prior=
ity.
> > >
> > > Below is as far as I got in integrating your patch last week, it shows
> > > only the major changes. The following bits have been updated:
> > >
> > >  * skb->priority now cleared before passing the skb onto layer 3;
> > >  * order of statements in prio_push() reversed (first dropping worst
> > >    skb and then pushing the new skb - this is better when e.g.
> > >    tx_qlen=3D1);
> > >  * added general parsing routine for cmsg(3) socket control messages
> > >    and defined one for the SOL_DCCP socket level; thanks to advice
> > >    by Dave Miller
> >
> > If this usage of skb->priority is going to override the
> > IP_TOS socket option setting, I don't think it's a good
> > idea.
> >
> > Right now every packet output goes through ip_output.c
> > which sets skb->priority to sk->sk_priority, which is set
> > by the user via the IP_TOS socket option in ip_sockglue.c
> >=20
> But I guess this assignment happens a bit later (that is after outgoing p=
acket=20
> leaves DCCP code). Consequently using skb->priority should not harm as it=
=20
> will be overwritten. Or did I miss something?

I haven't read all the patches, but I guess Tomasz is on the safe side
as the intended skb->priority usage is limited to DCCP, when IP is
handed the skb it can do as it pleases with skb->priority.

- Arnaldo
