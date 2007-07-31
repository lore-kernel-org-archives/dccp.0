From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 31 Jul 2007 22:00:16 +0000
Subject: Re: [PATCH 5/5]: Revert use of MSS instead of s
Message-Id: <5640c7e00707311500l29383aa0k6f473454fedc61e4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.53153@strip-the-willow>
In-Reply-To: <200707261356.53153@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there Gerrit,

Sorry for slow response. A bit behind on my emails at present.

On 7/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  I want to think about this. In particular the reference to VoIP - go
> |  look at CCID4 and that's EXACTLY what they do in effect (but standard
> |  frames - not jumbo).
>  The reference to VoIP/jumbo frames is not relevant in this context, what is
> relevant is thatthe code did not correspond to the current state of what
> several documents specify to use as default for `s'. That's enough justification
> for me.

Now I've read more my comment was wrong. I've gone back and found that
MSS changed to s in bis/FR arising out of Arjuna's comments. It was
MSS though in 4342. I never picked this up earlier.
>
> I don't understand the above comment about VoIP.

Ignore it.
>
> |  I'm heading down the patch that we should set 3448bis via a socket
> |  option as well as faster restart but maybe that's a question we should
> |  ask on the IETF list.
> If you want to do this and come back with some usable results to this list, feel free
> to do this. I'd like to hear the results, but don't want to participate in IETF discussions.
> I have lots of other work to do and am doing the DCCP/CCID3 work on top of it / aside
> of it. That means for me `technical support yes' but `research discussions on the IETF
> list (which is a specification list): no'.
>
Understand what you are saying.

> |  It really depends on whether existing TFRC is meant to be phased out and
> |  replaced or whether the application can choose - like a lot of TCP
> |  enhancements e.g. SACK. I think 3448bis should be the default but whether
> |  the only option is another question...
> I disagree with the idea. It is already the case that the many documents (3448, 4340,
> 4342, rfc3448bis, Faster Restart draft) all make related, but in a subtle way different
> interpretations of the same thing. I recall that when I did the patches, I would spend
> reading up to two or three hours the different drafts, because they are all not really
> consistent. What you are proposing is a parallel implementation of both the orthodox
> RFC 4342/3448 if I understand you correctly. With that you only increase the number of
> nightmares, since now you need not only align drafts, but also track sub-changes of
> different drafts in the code.
>
OK. Herein lies my problem. For my research I want to see what
improvements Faster Restart make to performance of my tests. However
as you point out it is quite complicated. I absolutely don't think we
should be tracking differences between 3448 (original) and 4342 - it
is clear 4342 takes precedence. If we implement drafts we need to
update with any changes but we don't need to keep past history there -
only latest version of draft. For me personally I need to track Faster
Restart. Where it's becoming an issue for me though is that there is
overlap between FR and 3448bis. It's causing me a bit of grief to be
honest.

Now as what is best for the Linux kernel - as opposed to what is best
for me, which is not the same thing :-(. I believe 3448bis changes
should be brought into code without having option to enable/disable -
much like Reno in the kernel is really NewReno. I think Faster Restart
should be an option though much like SACK, ABC, FRTO are in the
kernel.

> My suggestion is to keep the most common-sense collection of features as default and
> to do everything else on a case-by-case or experimental basis. Already the code is not
> really orthodox RFC 4342, we have for instance the Request/Response RTT sample which
> is not part of the document, and there are several other features (can list them if
> needed) that make the code not a true RFC 3448/4342 implementation.
>
If you do have a list of them it would be great. I see quite a few
comments about bis in the code.

> We could fork subtrees for such features, how about this? That would keep defaults
> and new features separate, at least for a while, and they can be integrated when the
> specification gains maturity.
>
I'm against forking trees if at all possible as it makes tracking
changes a nightmare. However if my patches are purely experimental,
and won't ever make it into mainline (e.g. my send best packet next)
I'll keep them as a separate patch series which can be a separate
branch if needed/wanted.
>
> So what is your stance regarding the `s' vs `MSS' issue? This patch is according
> to the book, I sent it to make your Faster Restart work a bit easier, and you
> are saying you don't want it?
>
I do want the s and I want the MSS as outlined earlier. However your
patch is valid and it's up to me to patch to allow both for my
research!

Thanks,

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
