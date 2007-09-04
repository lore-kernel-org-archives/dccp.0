From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 04 Sep 2007 21:45:02 +0000
Subject: Re: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <5640c7e00709041445w30934f12qde5b7693d7f2875e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200708291113.07431.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291113.07431.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  Agree. But don't think this is an obstacle to merging as we are
> |  running obsolete code in other branch/mainline ;-)
> |
> That is not what I meant. Of course it is not an obstacle of getting code `in', but the
> problem is in getting the code `out' or updated when there is time for a new revision.
>
> When there is little or no documentation in the code saying which variable or piece of
> code belongs where, then each time someone wants to change a bit of code has to reverse-
> engineer what actually is going on. This can be very time-consuming. So I was not thinking
> in terms of merging (although I am sure that Arnaldo will pick out bad code), but of keeping
> the code changeable for a longer period and easier to update.
>
> Don't get me wrong, I don't mean your code here, it is a general problem which I think we
> should pay more attention to. And, as said, my ideas of keeping things separate may not be
> the best possible solution, only one that I could think of at the moment.
>
Aha. I see what you mean now. I think the best thing to do here is to
label each block of code introduced, that is specific to a version,
with the version of the document used.

I actually think my code could be merged into your main branch (when I
resubmit it fixed) as it does not conflict with anything and doesn't
run by default.

>
> |  > * the CCID3 code is currently facing the following revisions
> |  > - the current code implements rev00
> |  > - Tommi's CCID4 relies on rev01 (not sure about Leandro's)
> |  > - your FR code actually would need rev02
> |  > - rev02 is in the process of being revised and obsoleted into rev03
> |  >
> |  Agree all the versions are a mess. I think it's worthwhile starting on
> |  upgrading the code base but not a project I'm undertaking at the
> |  moment (or you).
> Hopefully there will be some IETF consolidation about rfc3448bis in December, then all this
> could be reduced to one revision.
>
> Imagine -- 4 different developers and 3 different draft versions :(
>
I'm in two minds about this one. On my one hand as Linux developer I
think we should always be working towards the latest version. On the
other hand as a researcher I want a known and consistent quantity.
Difficult one to resolve!

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
