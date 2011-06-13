From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Mon, 13 Jun 2011 20:21:44 +0000
Subject: Re: Testing Tree Timeline
Message-Id: <BANLkTinVOp9y_-GO850VvFvdQ3gxfBz+GQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4DF637A8.5090104@ohio.edu>
In-Reply-To: <4DF637A8.5090104@ohio.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Samuel,

The way kernel code gets upstream is that whoever feels the most need
for it will take code and push it upstream. I did this with Arnaldo
earlier on and then Gerrit has largely taken over the reign. None of
us were doing it as our job but as an interest on the side. This is
why it sometimes becomes low priority.

I would encourage you then to try and do the same and send it off to
the netdev mailing list with cc to dccp, Gerrit and Dave Miller. Do
try to read the patch submission guides, but don't be discouraged when
you make mistakes in doing it as you will. You might get "flamed" even
but consider that your welcome to the kernel world, fix the mistakes
and carry on.

Regards

Ian

On 13 June 2011 17:15, Samuel Jero <sj323707@ohio.edu> wrote:
>
> Hello All,
>
> I was wondering what the current timeline looks like for integrating the
> patches in the testing tree into the mainline kernel?
>
> Myself, and several other researchers at Ohio University, believe that
> DCCP would be an ideal protocol for encapsulating Delay Tolerant
> Networking protocols for transportation across the Internet. For testing
> purposes, we do not desire guaranteed reliability, but do require
> congestion control.
>
> After testing (and bug fixing) DCCP for most of the last year, we are
> convinced that DCCP with CCID2 will be effective for our goals. In fact,
> we are in the process of writing an Internet Draft to recommend that
> other researchers use DCCP for encapsulating these DTN protocols.
>
> However, the CCID2 code in the mainline kernel is very buggy and suffers
> from very poor performance. As a result, the only way to get a version
> of CCID2 that works well is to build a custom kernel from the testing
> tree. This, obviously, puts a damper on adoption.
>
> As a result, it would be nice to have some idea of when code typically
> migrates from the testing tree into the mainline kernel and how that
> determination is made.
>
> Thanks.
>
> Samuel Jero
> Internetworking Research Group
> Ohio University
>
