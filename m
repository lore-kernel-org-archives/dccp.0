From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 16 Feb 2006 02:50:21 +0000
Subject: Re: [RFC] CCID infrastructure improvements
Message-Id: <39e6f6c70602151850g76ac2dcfy57dc4155dd033294@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70602151022v2d63a9d3nf88c0db59bfa36e9@mail.gmail.com>
In-Reply-To: <39e6f6c70602151022v2d63a9d3nf88c0db59bfa36e9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On 2/15/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> On 2/16/06, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> > Hi Ian, Andrea,
> >
> >        Can somebody please poke holes in the attached patch? It moves
> > more code out of the
> > CCIDs into the CCID infrastructure, simplifying some stuff.
> >
> >        With this rework ccid_operations becomes the struct proto
> > counterpart in ccid land (struct sock has a "operations" pointer to
> > struct proto).
> >
> >        I saw the need for this when working on Andrea's ccid feature
> > negotiation patch, that I'm
> > now reworking to take advantage of the attached patch.
> >
> As a baseline I downloaded acme-net-2.6.17.git and did some testing.
> When I test with netem in the middle between two boxes the transmitter
> locks solid....
>
> Test
> ./ttcp_acme -c -l500 -n100 -t jandi2
> ./ttcp_acme -c -l500 -r
>
> Netem configured as follows in middle box:
> sudo tc qdisc add dev lan1 root netem delay 50ms loss 10%
> sudo tc qdisc add dev lan0 root netem delay 50ms loss 10%
>
> I don't believe this happens with older version of DCCP (just pre
> CCID2) so I will start trying to track down....
>
> I don't have so much time so may take a little while. Feel free to
> investigate earlier if you wish.
>
> As such I haven't tested the patch as baseline not stable...
>

http://master.kernel.org/git/?p=3Dlinux/kernel/git/acme/net-2.6.17.git;a=3D=
shortlog;h=CCid_operations

I tested with the code that is in the "ccid_operations" of my
net-2.6.17 git tree (can
you give it a try? Perhaps I did some last minute fix over the one you test=
ed),
but without a middle box, tomorrow I'll revive this parisc and use
another machine
to test on real machines, not just qemu.

- Arnaldo
