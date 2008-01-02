From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 02 Jan 2008 02:40:59 +0000
Subject: Re: panic on 2.6.24rc5
Message-Id: <20080102024059.GH25000@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Wed, Jan 02, 2008 at 01:57:14AM +0100, Tomasz Grobelny escreveu:
> Dnia Wednesday 02 of January 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> > If the kernel oopses, if the results are the same or are some problem
> > introduced in the patches by Gerrit. I.e. you would help us to narrow
> > down the problem by trying a binary search of changeset history built
> > kernels.

> Oh, and by the way: does there exist any set of automated tests for dccp?=
 It=20
> would be nice to have one, wouldn't it? Otherwise accepting any patch is =

> quite risky...

There are test programs, documented in the wiki, and there is peer
review too :-)

And DCCP on Linux was written in such a way that a large part of its
core engine is actually shared with TCP, benefiting from a much bigger
set of developers and testers.

But please feel free to add more automated tests, it'll benefit us all.

- Arnaldo
