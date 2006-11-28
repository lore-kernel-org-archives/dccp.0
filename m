From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 28 Nov 2006 21:38:10 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <39e6f6c70611281338w18236992r3119a9774d5e866b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/28/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 11/28/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > > OK, additionally I'm replacing:
> > >
> > > +               DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
> > > +               err = -EINVAL;
> > >
> > > By
> > >
> > > +               DCCP_WARN("sockopt(PACKET_SIZE) not yet supported\n");
> > > +               err = -EINVAL;
> > >
> > > To better reflect what we've discussed so far.
> > >
> > No deprecate it still. My earlier patches split it into two - a tx and
> > rx packet size.
>
> Oh, I see, OK.

Applied the "deprecated" patch, and on top of that another that makes
it return 0, not -EINVAL, so that the warning is emitted to the system
logs but the app continues working, reflecting the comment that says
it is has no effect.

- Arnaldo
