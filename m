From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 26 Oct 2006 22:45:22 +0000
Subject: Re: [PATCH 0/17] [DCCP]: patch-backlog, bug-fixes, some code simplifications
Message-Id: <5640c7e00610261545s1a84a02an7b5f10d6e33056a8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200610241458.51517@strip-the-willow>
In-Reply-To: <200610241458.51517@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/26/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hi Arnaldo
>
> |  Gerrit, now I have a work related meeting, but later today I'll
> |  try and review these patches and get them into a
> |  net-2.6.20 tree
> Given that you are busy (as we know), I have set up the following to
> make things simpler and avoid getting into the same situation:
>
>         * I uploaded all patches from yesterday on to
>           http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/
>
>         * there is a `series' file to use with stgit/quilt; otherwise,
>           for i in $(<series); do git apply < $i; done
>
>         * only patches submitted onto the list will be put there
>
>         * daily update since it is from my repository
>
>         * future submissions (whether from me or anyone else) will be
>           added
>
>         * all keep the original signed-off lines and descriptions at top
>
>         * the whole lot (series and patches) can be downloaded as:
>           http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/the_whole_lot.tar.gz
>
> This is probably simpler than pulling an entire tree, but if you prefer that,
> let me know.
>
> Gerrit

Really, really helpful Gerrit. Owe you some beers when we eventually
meet at some conference. (As well as owing Arnaldo, Andrea et al beer
for their efforts as well!)

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
