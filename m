From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 28 Nov 2006 21:27:59 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <39e6f6c70611281327g3f71badev896db09475be0320@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/28/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 11/28/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > > > In short: my suggestion is to keep an experimental patch for this and I would even offer to
> > > >           keep one up-to-date and online, if in return we can simplify the socket API. Does
> > > >           this sound like a more convincing argument?
> > >
> > > Fair enough, I think we should go this way for now, please post here
> > > the patch that provides the experimental feature of explicitely
> > > setting the packet size, interested people can try and use it and
> > > report their findings, later we can get back and possibly merge the
> > > patch if it proves useful.
> > >
> > Basically my patches from a month or two ago would do this with a  few
> > changes. I'd say merge average patch, I'll update mine to go on top
> > (tomorrow??) and allow a mechanism to switch to use it.
>
> OK, additionally I'm replacing:
>
> +               DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
> +               err = -EINVAL;
>
> By
>
> +               DCCP_WARN("sockopt(PACKET_SIZE) not yet supported\n");
> +               err = -EINVAL;
>
> To better reflect what we've discussed so far.

Ah, also s/-EINVAL/-EOPNOTSUPP/g

- Arnaldo
