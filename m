From: Florian Westphal <fw@strlen.de>
Date: Thu, 07 Jun 2007 20:32:35 +0000
Subject: Re: 'BUG: scheduling while atomic' during dccp transfer
Message-Id: <20070607203235.GB32086@Chamillionaire.breakpoint.cc>
List-Id: <dccp.vger.kernel.org>
References: <20070607194353.GA32086@Chamillionaire.breakpoint.cc>
In-Reply-To: <20070607194353.GA32086@Chamillionaire.breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> >While transmitting data via dccp (Linux 2.6.21) I encountered this:
> >
> >BUG: scheduling while atomic: firefox-bin/0x10000100/6792
[..]

> Can you try with the attached patch?

I haven't been able to reproduce it so far.

Thanks!

Florian
