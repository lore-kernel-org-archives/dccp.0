From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 01 Aug 2007 22:00:19 +0000
Subject: Re: [PATCH 5/5]: Revert use of MSS instead of s
Message-Id: <5640c7e00708011500n5c7703dbs1a1b409b6e5c5626@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.53153@strip-the-willow>
In-Reply-To: <200707261356.53153@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Can understand that - that is partly why I suggested to wait a little, and see if and the
> two drafts stabilise. If there were updates to 4342 then I would also be all for tracking
> them. However, 4342 is written in such a clever way that updates of 3448 do not apply.
> I am in support of the 3448 draft changes that are in the kernel so far, since to my
> understanding they improve the performance over an `orthodox' 4342; the point being that
> no one cares how orthodox the implementation is when the performance is awful.
>
Unfortunately I can't really wait too long as it is for my thesis.
That's OK as I can reference which draft I use. It has been suggested
for CCID3.bis (and agreed) that CCID3 should track TFRC.

> |  If you do have a list of them it would be great. I see quite a few
> |  comments about bis in the code.
> I don't have a list at present, need to go through the works. Will post at a later point.
>
Don't worry too much about this, as this is my research so don't want
to waste your time :-)

> Forking trees is actually not so bad with regard to tracking the changes. I am doing that
> frequently for the test tree when the netdev tree changes. If there are not too many subtrees,
> (more than a handful), I'd say that this is feasible. It also makes it easier to track what
> is going on, and can be used as a temporary workspace while patch sets are under discussion.
>
Yes, that's what I do in effect - I work off your tree and occasionally resync.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
