From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 21 Oct 2007 01:56:32 +0000
Subject: Re: [RFC]: field name identifier conventions
Message-Id: <5640c7e00710201856j522ada41yb836a908ecfb8104@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710201654.35326@strip-the-willow>
In-Reply-To: <200710201654.35326@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/21/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I have a question/suggestion for DCCP/CCID field names, which have a tendency to grow
> into really_quite_long_strings. The convention for field members seems to be
>
>
>         "x"->"x"_<fieldname>
>
> Examples are in particular
>
>    * hctx->ccid2hctx_<fieldname>
>    * hcrx->ccid3hcrx_<fieldname>
>    * avr->dccpavr_<fieldname>
>    * av->dccpav_<fieldname>
>
> The problem is that this naming convention has no apparent benefits:
>
>   * which struct is used is evident from the context and need not be encoded
>   * someone reading the code is only interested in the fieldnames
>   * with the line length limit of 80 characters this convention almost inevitably leads to
>     multi-line expression for even the simplest kinds of comparisons and expressions.
>
> Hence my suggestion is to reduce the replicated "x" field prefix, so that field members become
> shorter, as will be expressions, and the code would be easier to read.
>
> What is the opinion of other developers / maintainer regarding this?
>
I agree with you totally.

I think the best way to do this is once Arnaldo agrees and then
prepare a big patch to do this. If we don't get Arnaldo's buy in then
it will be hell to maintain the patch set. This approach will still be
a pain as you'll probably have to redo your exisiting patches but it
is better to do it once then multiple times.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
