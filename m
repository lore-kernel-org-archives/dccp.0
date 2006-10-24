From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 24 Oct 2006 08:23:07 +0000
Subject: Re: 2.6.19-rcX vs 2.6.20
Message-Id: <5640c7e00610240123k513bf7b6m859f5ec29c09a583@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200610240848.47708@strip-the-willow>
In-Reply-To: <200610240848.47708@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/24/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> It seems that I am not the only one having headaches about which patches
> are applied and which not. I spent a major part yesterday trying to get
> the set of patches consistent with regard to Dave's/Arnaldo's latest tree.
>
<snipped>

My general philosophy of patching/maintaining it is as follows:
- When Dave M hasn't got a revision+1 tree open I just use Linus' tree
unless there is good reason. The reason for this is that you don't
have to rebase all the time
- When Dave M has a revision+1 tree open I use that (e.g. will need to
use net 2.6.20 soon I imagine)
- Whatever tree I use I use stgit on top of it on a separate branch. I
generally "stg export -d -n" to put all patches into subdirectory,
"stg pop -a" to pop the patches off, do a "stg pull" and then start
applying/deleting patches as I go.
- I have been using git apply --check as well which basically mirrors
the script of Gerrit's.

I publish my patch sets up to http://wand.net.nz/~iam4/dccp/patches
and have a file description.txt file there to describe what I have.

I can't reiterate enough how much stgit has helped me!!

I could put up a git tree if required but is it worth it for the
number of patches I do for the effort I would need to put in?

I would like to see bug fixes in 2.6.19 too if they are obvious fixes
e.g. the one I sent today. I won't get into the debate about other
cosmetic ones....

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
