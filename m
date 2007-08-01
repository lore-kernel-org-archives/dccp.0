From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 01 Aug 2007 13:55:07 +0000
Subject: Re: [PATCH 5/5]: Revert use of MSS instead of s
Message-Id: <200708011455.08112@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.53153@strip-the-willow>
In-Reply-To: <200707261356.53153@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > | =A0It really depends on whether existing TFRC is meant to be phased =
out and
|  > | =A0replaced or whether the application can choose - like a lot of TCP
|  > | =A0enhancements e.g. SACK. I think 3448bis should be the default but=
 whether
|  > | =A0the only option is another question...
|  > I disagree with the idea. It is already the case that the many documen=
ts (3448, 4340,
|  > 4342, rfc3448bis, Faster Restart draft) all make related, but in a sub=
tle way different
|  > interpretations of the same thing. I recall that when I did the patche=
s, I would spend
|  > reading up to two or three hours the different drafts, because they ar=
e all not really
|  > consistent. What you are proposing is a parallel implementation of bot=
h the orthodox
|  > RFC 4342/3448 if I understand you correctly. With that you only increa=
se the number of
|  > nightmares, since now you need not only align drafts, but also track s=
ub-changes of
|  > different drafts in the code.
|  >
|  OK. Herein lies my problem. For my research I want to see what
|  improvements Faster Restart make to performance of my tests. However
|  as you point out it is quite complicated. I absolutely don't think we
|  should be tracking differences between 3448 (original) and 4342 - it
|  is clear 4342 takes precedence. If we implement drafts we need to
|  update with any changes but we don't need to keep past history there -
|  only latest version of draft. For me personally I need to track Faster
|  Restart. Where it's becoming an issue for me though is that there is
|  overlap between FR and 3448bis. It's causing me a bit of grief to be
|  honest.
Can understand that - that is partly why I suggested to wait a little, and =
see if and the
two drafts stabilise. If there were updates to 4342 then I would also be al=
l for tracking
them. However, 4342 is written in such a clever way that updates of 3448 do=
 not apply.
I am in support of the 3448 draft changes that are in the kernel so far, si=
nce to my
understanding they improve the performance over an `orthodox' 4342; the poi=
nt being that
no one cares how orthodox the implementation is when the performance is awf=
ul.
 =20
|  I believe 3448bis changes should be brought into code without having opt=
ion to=20
|  enable/disable -  much like Reno in the kernel is really NewReno.=20
Yes, agree fully with that point. Am not fully sure about the status of 344=
8bis, during
the past 5 months there have been heavy, frequent and also retracted change=
s.

|  I think Faster Restart should be an option though much like SACK, ABC, F=
RTO are in the
|  kernel.
Makes sense. I thought your concept of using a socket option was a good one=
, since it
could be reused later for CCID4 (it is not a single-CCID socket option).

|  > Already the code is not really orthodox RFC 4342, we have for instance=
 the=20
|  > Request/Response RTT sample which is not part of the document, and the=
re are several=20
|  > other features (can list them if > needed)=20
|  If you do have a list of them it would be great. I see quite a few
|  comments about bis in the code.
I don't have a list at present, need to go through the works. Will post at =
a later point.

=20
|  > We could fork subtrees for such features, how about this? That would k=
eep defaults
|  > and new features separate, at least for a while, and they can be integ=
rated when the
|  > specification gains maturity.
|  >
|  I'm against forking trees if at all possible as it makes tracking
|  changes a nightmare. However if my patches are purely experimental,
|  and won't ever make it into mainline (e.g. my send best packet next)
|  I'll keep them as a separate patch series which can be a separate
|  branch if needed/wanted.
Forking trees is actually not so bad with regard to tracking the changes. I=
 am doing that
frequently for the test tree when the netdev tree changes. If there are not=
 too many subtrees,
(more than a handful), I'd say that this is feasible. It also makes it easi=
er to track what
is going on, and can be used as a temporary workspace while patch sets are =
under discussion.
