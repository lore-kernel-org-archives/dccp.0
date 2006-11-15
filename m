From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 15 Nov 2006 17:33:06 +0000
Subject: Re: [RFC] [PATCH]: use explicit enums for CCID 3 states
Message-Id: <5640c7e00611150933l56183304l8ed88ea76dc1065e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611151401.41404@strip-the-willow>
In-Reply-To: <200611151401.41404@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/16/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 11/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > |  Anyway, there are always tradeoffs, compiler gets more info, but we
> > |  end up using more memory per socket instance, I guess we can stay like
> > |  we are now, no? :-)
> > That is why I sent it as RFC in the first place: it is not broken but would
> > be good to have.
> >
> > I will think about a solution without changing the socket fields,
> > would BUG be ok instead of the more verbose output? But then, it is not so
> > terribly important, it just makes the code harder to understand.
>
> Well, I'd rather prefer a WARN_ON type, probably rate limiting the
> printks, so that we can receive reports that something is fishy but
> don't panic the machine.
>
Whatever you do do not put BUG back in place of a dump_stack that I've
put in the code!! The reason for this is that if you do a BUG when you
have the bottom half locked your machine comes to a screaming halt.
What's worse is it does not appear in the logs but only in the console
as it doesn't sync the filesystems but just stops the machine dead.

I learnt this the hard way!

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
