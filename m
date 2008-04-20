From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 20 Apr 2008 16:57:42 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080420165742.GA12221@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Sat, Apr 19, 2008 at 10:42:32PM +0200, Tomasz Grobelny escreveu:
> Dnia Friday 18 of April 2008, Gerrit Renker napisa=C5=82:
> > | > There is a more serious problem here: apparently no one tried to
> > | > compile the `qpolicy' subtree since the changes on Monday. It fails
> > | > with the BUILD_BUG_ON.
> > | >
> > | > I tried yesterday evening and found that there is not even a
> > | > possibility of adding a single field to struct dccp_skb_cb: with the
> > | > addition of the inet{,6}_skb_parm, the struct has reached its maxim=
um
> > | > size of 48 bytes (try printk("%u", sizeof(struct dccp_skb_cb));).
> > | >
> > | > There is a solution to this, will post a revised patch shortly.
> > |
> > | What you proposed in the patch should work ok for qpolicies for now. =
But
> > | sooner or later the need to add a field to struct dccp_skb_cb will ar=
ise.
> > | So maybe we should think about it now...
> > | Other possibility apart from what you proposed in the patch is creati=
ng
> > | struct dccp_skb_cb_ext, move to it some fields from struct dccp_skb_cb
> > | and in struct add a pointer to this new struct dccp_skb_cb_ext. Ok, m=
aybe
> > | it is not the prettiest idea but in case somebody needs yet another
> > | additional field in struct dccp_skb_cb_ext it would be nice to have an
> > | idea how to do it.
> >
> > When the patch failed to compile I thought about those alternatives.
> > Trying to extend the dccp_skb_cb over and above what is in there will be
> > messy, since the IPv4/v6 parameters are required by other subsystems.
> >
> If inet{,6}_skb_parm is used only outside DCCP code then why at all shoul=
d it=20
> be placed in struct dccp_skb_cb taking up quite a lot of valuable space? =
Why=20
> not put it directly in struct sk_buff? Especially that it is present in=20
> struct udp_skb_cb, struct tcp_skb_cb as well.

Because all this is used in skb->cb[], a scratchpad for protocols to
use, we can go back to what we had before, that is to not reserve use
for inet6?_skb_parm but be sure to zero it before passing it to IP, as
we don't want IP to be confused with things being non zero there. Then
we can use all its space.

- Arnaldo
