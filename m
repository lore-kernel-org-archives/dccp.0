From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Fri, 21 Sep 2007 19:49:21 +0000
Subject: Re: [PATCH 2/4] CCID4: Provides organization to the initial entries for CCID 4 to net/dccp/ccids/Mak
Message-Id: <5bc4c4570709211249ya535d03w5fa71cff80f4debe@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201054n1beda2d8x6bfdcda0cbcbaa35@mail.gmail.com>
In-Reply-To: <5bc4c4570709201054n1beda2d8x6bfdcda0cbcbaa35@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/21, ツ Leandro Sales <leandroal@gmail.com>:
> 2007/9/21, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>:
> > Em Fri, Sep 21, 2007 at 05:02:40PM +0300, Tommi Saviranta escreveu:
> > > On Thu, Sep 20, 2007 at 14:54:32 -0300, ツ Leandro Sales wrote:
> > > > diff -uprN dccp-ccid4.base/net/dccp/ccids/Makefile
> > > > dccp-ccid4/net/dccp/ccids/Makefile
> > > > --- dccp-ccid4.base/net/dccp/ccids/Makefile 2007-09-20 11:45:30.000000000 -0300
> > > > +++ dccp-ccid4/net/dccp/ccids/Makefile      2007-09-20 11:55:23.000000000 -0300
> > >
> > > Signed-off-by: Tommi Saviranta <wnd@iki.fi>
> > >
> > > By the way one more question about acking/signing patches. When talking
> > > about trivial patches such as this, is there a consensus on if simple
> > > patches need to be (or should be) acked or signed in the first place?
> > >
> > > Personally I was a little reluctant to sign this one, but signed it
> > > anyway as requested.
> >
> > It is always good to show that you agree with the change, read
> > Documentation/SubmittingPatches to get more food for thought.
> >
> > I'll try to harvest the signatures when I get to review/merge the
> > patches.
> >
> > And keep up the good work, I'm really happy with how healthy the DCCP on
> > Linux developer community is getting, thank you all!
> >
> > - Arnaldo
> >
>
> I just update the file thinking about the future changes to the DCCP
> implementation, for instance, adding new CCIDs. Since I have other
> patches to apply, I decided to submit this one too. Since we were
> submit initial patches for CCID-4, I considerer that this initial
> process will require some adjusts like that. Besides, our patches (the
> mine and Tommi's ones) was very similar, and them I just sent the
> remains patches.
>
> Tommi, when you agree with some patch, you can send a NAK ("no ack"),
> as Gerrit said.
>
> Arnaldo, it is good to know from you that our works are welcomed.
>
> Leandro.
>

ERRATA: when you don't agree, you can send a NAK.
