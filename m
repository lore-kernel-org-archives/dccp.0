From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 26 Sep 2007 23:41:22 +0000
Subject: Re: Towards the ccid-3 and ccid-4 integration
Message-Id: <5640c7e00709261641n4efbb0aeq53e396d9af38ea56@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
In-Reply-To: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/27/07, Tommi Saviranta <wnd@iki.fi> wrote:
> On Mon, Sep 24, 2007 at 15:15:57 -0300, ツ Leandro Sales wrote:
> > - Identify and provide common code between ccid-4 and ccid-3.
>
> I'm probably little too much of a need-get-my-hands-dirty kind of guy,
> but I think this part usually works out the best while actually doing
> the split. I don't want to scare people away by telling this, but if I
> was working on the split alone, I'd start by moving everything in
> ccid3.c to lib/ccid3.c, and then moving stuff back to ccid3.c in pieces
> as certain functions would have to be rewritten for CCID 4.
>
Yes it's best to experiment and then tidy later often.

> >   1 - minor functions from ccid-3.c to ccid-3.h and include it (.h) in
> > the ccid-4.c, as suggested by Ian and Arnaldo
> >   2 - for more complex functions, write a dccp_ccid3_lib.ko, as
> > suggested by arnaldo
>
> There is very little more to say about this, really. The code should and
> needs to be shared. I just have this bad feeling that ccid3.c will
> become nothing but a skeleton file that does all the work in
> dccp_ccid3_lib.
>
And that's fine. There will be some methods that are different - like
calculating the ipi - and this would then be in ccid3.c and ccid4.c
but not in dccp_ccid3_lib.c

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
