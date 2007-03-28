From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 28 Mar 2007 20:07:07 +0000
Subject: Re: [PATCH 1/1][DCCP] getsockopt: Fix DCCP_SOCKOPT_[SEND,RECV]_CSCOV
Message-Id: <5640c7e00703281307t74b17143s33810343bac9754a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070328151531.GD20303@ghostprotocols.net>
In-Reply-To: <20070328151531.GD20303@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/29/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 3/28/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > Part of the issue here is possibly that we are using signed ints here
> > and the type from userspace is socklen_t which by my quick check is
> > unsigned on my system.
> >
> > I haven't checked how this is defined on other architectures yet but
> > if this is the case we should tidyup to remove other possible errors
> > of this type. I'll look into this some more as time permits.
> >
> > Or am I talking through a whole in my head?
> >
>
> One way or the other we are safe now, no?
>
Absolutely we are safe. I'm just thinking of removing possible vectors
for future problems.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
