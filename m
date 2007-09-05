From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 05 Sep 2007 10:02:24 +0000
Subject: Re: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <5640c7e00709050302m1e3655em49b882b3ee966f21@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200708291113.07431.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291113.07431.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  Aha. I see what you mean now. I think the best thing to do here is to
> |  label each block of code introduced, that is specific to a version,
> |  with the version of the document used.
> That's why I thought a separate branch would be nice - it keeps all documentation and patches together
> so that even after some pauses in between one knows where the code came from and what it was good for.
>

That's fine by me.

> Will you be updating the code when the `real' Faster Restart comes out? We talked about this before,
> the situation is that rev-03 is obsolete and in the progress of being replaced by a different approach, so
> the current incarnation is in a kind of disconnected limbo state. It is useful for testing, and that is
> why I am certainly happy to track it in (a branch of) the tree; but it is clear that this Faster Restart
> will be obsoleted in some future.
>

I would be interested in doing so, but it all depends what else I am
doing when that comes around.

> That is why I think a separate branch is better - it allows you, even after months of pause, to continue
> with your Faster Restart work exactly where it was left previously.
>
Fine by me.

> Let me be clear - I don't want to get in the way of style discussions between you and Arnaldo, but I'd
> like to keep the test tree as clearly structured as possible. What I don't know at the moment, and shall
> investigate, is whether there are other ways of arranging the subtrees while still keeping different
> approaches separable (my understanding of a `branch').
>
It's no big issue really to me how it is stored. I have my
preferences, but I don't really care how it is actually done in the
end.


> So, my hope is that if we can resolve this satisfactorily for you and all others involved, we will arrive
> at a generic solution of distributed development, as I am quite sure that the problem of moving targets will
> persist in the DCCP world for some time to come.
>
It is resolved satisfactorily for me now.

Regards,

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
