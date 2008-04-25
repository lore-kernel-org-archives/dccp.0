From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 25 Apr 2008 19:33:11 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804252133.11264.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 23 of April 2008, David Miller napisa=B3:
> From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Date: Tue, 22 Apr 2008 18:41:52 +0100
>
> > | If we iron this out we could finally return to the main subject of th=
is
> > | thread. That is Patch v2 by me and Gerrit...
> > | --
> >
> > Fully agree - we just need to decide whether or not to use skb->priorit=
y.
> >
> > Below is as far as I got in integrating your patch last week, it shows
> > only the major changes. The following bits have been updated:
> >
> >  * skb->priority now cleared before passing the skb onto layer 3;
> >  * order of statements in prio_push() reversed (first dropping worst
> >    skb and then pushing the new skb - this is better when e.g.
> >    tx_qlen=3D1);
> >  * added general parsing routine for cmsg(3) socket control messages
> >    and defined one for the SOL_DCCP socket level; thanks to advice
> >    by Dave Miller
>
> If this usage of skb->priority is going to override the
> IP_TOS socket option setting, I don't think it's a good
> idea.
>
> Right now every packet output goes through ip_output.c
> which sets skb->priority to sk->sk_priority, which is set
> by the user via the IP_TOS socket option in ip_sockglue.c
>=20
But I guess this assignment happens a bit later (that is after outgoing pac=
ket=20
leaves DCCP code). Consequently using skb->priority should not harm as it=20
will be overwritten. Or did I miss something?
--=20
Regards,
Tomasz Grobelny
