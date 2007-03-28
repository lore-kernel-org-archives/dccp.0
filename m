From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Wed, 28 Mar 2007 19:36:37 +0000
Subject: Re: [PATCH 1/1][DCCP] getsockopt: Fix DCCP_SOCKOPT_[SEND,RECV]_CSCOV
Message-Id: <39e6f6c70703281236y5e257bdcx699a2a7fe7335c7b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070328151531.GD20303@ghostprotocols.net>
In-Reply-To: <20070328151531.GD20303@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/28/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 3/29/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> > David,
> >
> >         Please push for 2.6.21 and stable (CCed for good measure).
> >
> > - Arnaldo
> >
> > -----------------------------------
> >
> > We were only checking if there was enough space to put the int, but left len as
> > specified by the (malicious) user, sigh, fix it by setting len to sizeof(val) and
> > transfering just one int worth of data, the one asked for.
> >
> > Also check for negative len values.
> >
> Part of the issue here is possibly that we are using signed ints here
> and the type from userspace is socklen_t which by my quick check is
> unsigned on my system.
>
> I haven't checked how this is defined on other architectures yet but
> if this is the case we should tidyup to remove other possible errors
> of this type. I'll look into this some more as time permits.
>
> Or am I talking through a whole in my head?
>

One way or the other we are safe now, no?

- Arnaldo
