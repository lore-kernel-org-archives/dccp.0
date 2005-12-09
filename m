From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 09 Dec 2005 18:22:26 +0000
Subject: Re: dccp socket sometimes not destroyed upon close
Message-Id: <39e6f6c70512091022g22bfb914k21b816749b81329e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0512081847s7856344ayd46be225d2f903a2@mail.gmail.com>
In-Reply-To: <cbec11ac0512081847s7856344ayd46be225d2f903a2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/9/05, Ian McDonald <imcdnzl@gmail.com> wrote:
> On 11/19/05, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> > When a socket is closed, inet_csk_destroy_sock should be called [currently done
> > by dccp_close()].  This will exit the ccids and bump down the module use count
> > [so that you can unload the module].
> >
> > dccp_close() will try to close the socket.  If it remains in state DCCP_CLOSING,
> > it will setup a timer for re-transmitting the "close-req" packet.  In this case,
> > inet_csk_destroy_sock() will not be called [it is only called if state is
> > DCCP_CLOSED].  If the socket is closed successfully after the re-transmission,
> > inet_csk_destroy_sock() will never be called.
> >
> >
> > My way of fixing it is adding at the end of dccp_rcv_close() something like:
> >         if (atomic_read(sk->sk_prot->orphan_count) &&
> >             dccp_sk(sk)->dccps_hc_rx_ccid)
> >                 inet_csk_destroy_sock(sk);
> >
> > Adding dccp_done() might work.  I noticed some calls to dccp_done() when
> > re-transmits fail.  Thus, if the other host totally dies, the socket should be
> > destroyed [i hope] and this bug shouldn't exist.
> >
> >
> > The main reason why I am posting this is that I wanted to know the correct fix.
> > I am interested in it primarily for being able to unload the module.
>
> Andrea - agree with you that it needs fixing. I've got the same
> problem at the moment - annoying to reboot to unload module...
>
> When I look at section 8.3/8.4 of the spec for DCCP I think we need a
> bit of a rewrite on the closing code - which is backed up by Arnaldo's
> comments. At present we are too TCP like and DCCP has quite a
> different way for closing compared to TCP.
>
> I just started looking at how this could be fixed but my head hurts
> quickly when trying to work it out. Also I'm not entirely sure that
> dccp_done is safe as it doesn't lock the socket at all...

Look at the OSTRA callgraphs at
http://oops.ghostprotocols.net:81/dccp/ostra, there you can see the
flow and it may help you.

The current code was, yes, modelled after the TCP structure, now that
we have more people working on it and seeing the flaws, we can discuss
about DCCP needs and strive to figure out a INET (v4/v6) core API that
can serve both TCP and DCCP :-)

/me still swamped with work, but trying to follow the discussions :-)

- Arnaldo
