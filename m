From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 24 Oct 2006 16:03:53 +0000
Subject: Re: [PATCH 0/17] [DCCP]: patch-backlog, bug-fixes, some code simplifications
Message-Id: <39e6f6c70610240903h65b11515j7a41979a75ec58d7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200610241458.51517@strip-the-willow>
In-Reply-To: <200610241458.51517@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/24/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> As promised earlier, this is the set of patches which I have been
> keeping up-to-date; they divide into:
>
>         * patches sent to this list that have not been merged
>           [I claim that this is exhaustive, i.e. all other patches
>            have been merged - notify me if there is one missing]
>         * bug fixes
>         * `cosmetic' patches to simplify and consolidate code
>
> The set is consistent in itself and patches on top of the latest davem-2.6
> tree, but: all are stacked, i.e. the best way of applying is
>
>         for p in $patches; do git-apply < $p; done
>
> There are no new files introduced, so this works without problem. I have put
> in extra time to check / tidy each and every one. I hope that this will pay
> off, as I have little benefit from this and had to take this time away from
> other commitments.

Thanks a lot for this Gerrit, now I have a work related meeting, but
later today I'll try and review these patches and get them into a
net-2.6.20 tree

- Arnaldo
