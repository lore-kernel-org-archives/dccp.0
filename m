From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 28 Nov 2006 21:30:38 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <39e6f6c70611281330i7fbeaffbl6431024fa024a475@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/28/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > OK, additionally I'm replacing:
> >
> > +               DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
> > +               err = -EINVAL;
> >
> > By
> >
> > +               DCCP_WARN("sockopt(PACKET_SIZE) not yet supported\n");
> > +               err = -EINVAL;
> >
> > To better reflect what we've discussed so far.
> >
> No deprecate it still. My earlier patches split it into two - a tx and
> rx packet size.

Oh, I see, OK.

- Arnaldo
