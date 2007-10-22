From: Tommi Saviranta <wnd@iki.fi>
Date: Mon, 22 Oct 2007 11:20:15 +0000
Subject: Re: [RFC]: field name identifier conventions
Message-Id: <20071022112015.GA17862@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710201654.35326@strip-the-willow>
In-Reply-To: <200710201654.35326@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sat, Oct 20, 2007 at 18:39:23 +0300, Gerrit Renker wrote:
> I have a question/suggestion for DCCP/CCID field names, which have a
> tendency to grow into really_quite_long_strings. The convention for
> field members seems to be
> 
> 	"x"->"x"_<fieldname>

> The problem is that this naming convention has no apparent benefits: 
>   
>   * which struct is used is evident from the context and need not be
>     encoded
>   * someone reading the code is only interested in the fieldnames

I think reusing bits from structure name in field names is partly
traditional, partly ignorant. When I first took a look at DCCP's code, I
found the "x_" prefix somewhat explanatory, but it soon became annoyance
I would just have to live with.

> Hence my suggestion is to reduce the replicated "x" field prefix, so
> that field members become shorter, as will be expressions, and the
> code would be easier to read.
> 
> What is the opinion of other developers / maintainer regarding this? 

I agree, the prefixes are unnecessary.

