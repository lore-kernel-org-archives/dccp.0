From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 20 Apr 2008 20:12:12 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804202212.12283.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Sunday 20 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> Em Sat, Apr 19, 2008 at 10:42:32PM +0200, Tomasz Grobelny escreveu:
> > > When the patch failed to compile I thought about those alternatives.
> > > Trying to extend the dccp_skb_cb over and above what is in there will
> > > be messy, since the IPv4/v6 parameters are required by other
> > > subsystems.
> >
> > If inet{,6}_skb_parm is used only outside DCCP code then why at all
> > should it be placed in struct dccp_skb_cb taking up quite a lot of
> > valuable space? Why not put it directly in struct sk_buff? Especially
> > that it is present in struct udp_skb_cb, struct tcp_skb_cb as well.
>
> Because all this is used in skb->cb[], a scratchpad for protocols to
> use, we can go back to what we had before, that is to not reserve use
> for inet6?_skb_parm but be sure to zero it before passing it to IP, as
> we don't want IP to be confused with things being non zero there. Then
> we can use all its space.
>
Several questions regarding this case:
1. What about SCTP? It doesn't have inet6?_skb_parm in it's structure that =
is=20
stored in skb->cb. So does it contain a potential bug (that is to be fixed)=
=20
or is it not needed there or what?
2. If the sole purpose of this change was to keep skb->cb zeroed then it=20
doesn't seem to me like the right solution. Wasting about 20 bytes instead =
of=20
zeroing them when needed I would consider at least weird. I understand that=
=20
TCP and UDP may have enough space left but it just turned out that DCCP=20
doesn't.
3. If it's IP layer that needs zeroes then why not clear skb->cb in IP laye=
r?
--=20
Regards,
Tomasz Grobelny
