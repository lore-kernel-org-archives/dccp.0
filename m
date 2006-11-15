From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Wed, 15 Nov 2006 15:32:03 +0000
Subject: Re: [RFC] [PATCH]: use explicit enums for CCID 3 states
Message-Id: <39e6f6c70611150732i3f54106dqa3f357cdde9ccecc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611151401.41404@strip-the-willow>
In-Reply-To: <200611151401.41404@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  Anyway, there are always tradeoffs, compiler gets more info, but we
> |  end up using more memory per socket instance, I guess we can stay like
> |  we are now, no? :-)
> That is why I sent it as RFC in the first place: it is not broken but would
> be good to have.
>
> I will think about a solution without changing the socket fields,
> would BUG be ok instead of the more verbose output? But then, it is not so
> terribly important, it just makes the code harder to understand.

Well, I'd rather prefer a WARN_ON type, probably rate limiting the
printks, so that we can receive reports that something is fishy but
don't panic the machine.

> |
> |  Probably because we stop using a u64 bitfield in the rx case...
> Yes it is irksome - could not find anything to put in the 4-bit hole.
>
> -- Gerrit
>
