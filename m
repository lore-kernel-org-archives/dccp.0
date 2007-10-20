From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 20 Oct 2007 21:08:25 +0000
Subject: Re: [RFC]: field name identifier conventions
Message-Id: <20071020210825.GB4326@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200710201654.35326@strip-the-willow>
In-Reply-To: <200710201654.35326@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Oct 20, 2007 at 07:03:49PM -0200, Arnaldo Carvalho de Melo escreveu:
> Em Sat, Oct 20, 2007 at 04:54:35PM +0100, Gerrit Renker escreveu:
> > I have a question/suggestion for DCCP/CCID field names, which have a tendency to grow
> > into really_quite_long_strings. The convention for field members seems to be
> > 
> > 
> > 	"x"->"x"_<fieldname>
> > 
> > Examples are in particular
> > 
> >    * hctx->ccid2hctx_<fieldname>
> >    * hcrx->ccid3hcrx_<fieldname>
> >    * avr->dccpavr_<fieldname>
> >    * av->dccpav_<fieldname>
> > 
> > The problem is that this naming convention has no apparent benefits: 
> >   
> >   * which struct is used is evident from the context and need not be encoded
> >   * someone reading the code is only interested in the fieldnames
> >   * with the line length limit of 80 characters this convention almost inevitably leads to
> >     multi-line expression for even the simplest kinds of comparisons and expressions.
> > 
> > Hence my suggestion is to reduce the replicated "x" field prefix, so that field members become
> > shorter, as will be expressions, and the code would be easier to read.
> > 
> > What is the opinion of other developers / maintainer regarding this? 
> 
> Well, while I agree that the names being overly long its a nuisance at
> the same time being able to grep for some specific field is really nice
> and was the intention.
> 
> Long ago DaveM accepted patches for struct sock, but then there its just
> ->sk_FIELD_NAME, not 10 characters like in the ccids case. struct inode
> fields predate that even, but then its just ->i_FIELD_NAME.
> 
> I think that providing a unique namespace for struct member names is ok
> if it doesn't get that long (mea culpa in the aforementioned cases 8)).

Forgot to leave a suggestion for the mentioned case: ->c2tx_ perhaps :)

- Arnaldo

P.S.: What we really needed was more intelligent grep, ctags
replacements for quickly locating such information in C source files,
perhaps one that could understand types and then could allow developers
to ask questions like "show me all the places where the field foo of
type bar appears", but till then the old practice, albeit not uniformly
used of using a namespace alias in the form of a prefix seems to suit us
:-)
