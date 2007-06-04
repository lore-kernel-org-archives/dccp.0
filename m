From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 04 Jun 2007 20:53:18 +0000
Subject: Re: [PATCH 0/3] DCCP: Minor changes
Message-Id: <5640c7e00706041353x9287afat9a072dc9e7ccb618@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706041149.01701.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200706041149.01701.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Ian,

Hi Gerrit - comments inline.
>
> can you please finalise and send all outstanding patches, so as to get a complete picture.
> I see that the net-2.6.23 tree is not out yet, so it would be better to do this now.
> There is some overlap with my patch set, but I will need to rebase it against these changes
> before it can be submitted.
>

These patches are the final lot - these are still the patches from way
back when you were last posting patches on the net. They never got
merged since then. The reason why it keeps on appearing there are new
patches is that Arnaldo is fussy and I have to rewrite. I think it
will still be easier rebasing your patch set on these than the tree
without them as you were relying on a form of them previously.

As far as other patches go I don't have any at present. I'm thinking
of doing some dccp_probe patches to track changes in tcp_probe but
haven't done these yet and they would be well away from the other
changes and not conflict probably.

Any other congestion related patches if/when I write them I'll base on
your tree.

> The patch set I am proposing is not a panacea and will not solve all outstanding problems,
> but apart from the ones that it solves I believe it can be of help in resolving the outstanding
> problems; the sooner work and testing can start, the better.
>

Understand

> I can further identify with the problems reported on this list due to changes somewhere
> else in the kernel tree. I normally test using a different hardware (SMP, 32 bit, 64 bit,
> laptop, and some older PCs), but loyally tracking the recent changes in the bleeding edge
> tree often means that some equipment can not be used for a while.
> I think that this may be alleviated by not updating the base too frequently between kernel releaes
> in the upcoming `DCCP experimental' tree.

Yes Linus' tree can be at times unstable. I'd normally not use his
tree, unless I had to, until after about rc3 of any release. Of course
if you're trying to hit a merge window then you might need to track
the very latest.
>
> Gerrit
>
Ian

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
