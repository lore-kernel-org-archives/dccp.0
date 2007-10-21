From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Sun, 21 Oct 2007 02:54:22 +0000
Subject: Re: [RFC]: field name identifier conventions
Message-Id: <5bc4c4570710201954k779a23ebv8b1e501ef82a320@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710201654.35326@strip-the-willow>
In-Reply-To: <200710201654.35326@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/10/20, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>:
> Em Sat, Oct 20, 2007 at 07:03:49PM -0200, Arnaldo Carvalho de Melo escreveu:
> > Em Sat, Oct 20, 2007 at 04:54:35PM +0100, Gerrit Renker escreveu:
> > > I have a question/suggestion for DCCP/CCID field names, which have a tendency to grow
> > > into really_quite_long_strings. The convention for field members seems to be
> > >
> > >
> > >     "x"->"x"_<fieldname>
> > >
> > > Examples are in particular
> > >
> > >    * hctx->ccid2hctx_<fieldname>
> > >    * hcrx->ccid3hcrx_<fieldname>
> > >    * avr->dccpavr_<fieldname>
> > >    * av->dccpav_<fieldname>
> > >
> > > The problem is that this naming convention has no apparent benefits:
> > >
> > >   * which struct is used is evident from the context and need not be encoded
> > >   * someone reading the code is only interested in the fieldnames
> > >   * with the line length limit of 80 characters this convention almost inevitably leads to
> > >     multi-line expression for even the simplest kinds of comparisons and expressions.
> > >
> > > Hence my suggestion is to reduce the replicated "x" field prefix, so that field members become
> > > shorter, as will be expressions, and the code would be easier to read.
> > >
> > > What is the opinion of other developers / maintainer regarding this?
> >
> > Well, while I agree that the names being overly long its a nuisance at
> > the same time being able to grep for some specific field is really nice
> > and was the intention.
> >
> > Long ago DaveM accepted patches for struct sock, but then there its just
> > ->sk_FIELD_NAME, not 10 characters like in the ccids case. struct inode
> > fields predate that even, but then its just ->i_FIELD_NAME.
> >
> > I think that providing a unique namespace for struct member names is ok
> > if it doesn't get that long (mea culpa in the aforementioned cases 8)).
>
> Forgot to leave a suggestion for the mentioned case: ->c2tx_ perhaps :)
>
> - Arnaldo
>
> P.S.: What we really needed was more intelligent grep, ctags
> replacements for quickly locating such information in C source files,
> perhaps one that could understand types and then could allow developers
> to ask questions like "show me all the places where the field foo of
> type bar appears", but till then the old practice, albeit not uniformly
> used of using a namespace alias in the form of a prefix seems to suit us
> :-)
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

I think the arnaldo comments sounds appropriate. Particular for me,
the current nomenclature helped me in the fork from ccid3 to ccid4.
While reviewing the code (or search for something specific, like
arnaldo commented out) just having "hctx->last_counter" instead of
"hctx->ccid4hcrx_last_counter" in some cases will make us have to
backward to a certain parts of the code in order to understand if the
hctx was returned by a call to ccid3_hc_rx_sk() function, to the
ccid4_hc_rx_sk() function or by the new function that I will suggest
to you soon named ccid34_hc_rx_sk(), which will be a shared function
used by both, ccid3 and ccid4.

Well, I don't know if my comments make sense or not, mainly because
I'm new in the dccp hacking, but this is my opinion.  What about
follow the arnaldo suggestion, have something like
"hctx->c4_last_counter" rather than "hctx->ccid4hcrx_last_counter". In
this case, if we need to make a search for foo of type bar, we can
search for the string "tx->c4", or "rx->c4" (just a very specific
example):

# grep -r "tx->c4" *

Leandro.
