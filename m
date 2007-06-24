From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 24 Jun 2007 04:21:40 +0000
Subject: Re: [Announce]: How to access Experimental Test Tree
Message-Id: <5640c7e00706232121v4fcb3bf7wce96cef9e4425a0d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706221523.29662@strip-the-willow>
In-Reply-To: <200706221523.29662@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there Gerrit,

Thanks for these instructions. Very helpful. Unfortunately the
alternative way didn't work for me but the others did just fine.

Your tree looks very good when compiled as a whole. It passes all my
tests on CCID3 - the first time I've had this occur in ANY tree. Well
done! I'm going to post the results on the OSDL wiki soon - in
particular it passed tests at full speed over a routed link.

Ian

On 6/23/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Mainline kernel development takes a long time, even if changes are small, and
> DCCP is in some respects not a finished and fully tested protocol: to enable
> testing without the constraints of mainline development, a DCCP test tree
> has been set up - with patches taken from this list.
>
> People are encouraged to use this tree and report any findings and make suggestions.
>
> You can pull the entire tree but remember that git kernel sources are in the
> order of several hundred megabytes. Here are some suggestions to reduce the
> download size - and time.
>
> To pull the entire tree [expensive], use
>
>    git clone git://eden-feed.erg.abdn.ac.uk/dccp_exp.git my_dccp
>
> Much better, if you already have a linux git tree e.g. in /usr/src/linux-2.6, use
>
>    git clone --reference /usr/src/linux-2.6  git://eden-feed.erg.abdn.ac.uk/dccp_exp  my_dccp
>
>
> Even better: only pull the relevant `dccp' subtree:
> ---------------------------------------------------
> 1. The experimental tree is updated every work day from David Miller's tree
>    it is a good idea to take an up-to-date copy first:
>
>       git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
>
> 2. chdir into your up-to-date git repository
>
> 3. create a subtree `dccp' using the commands
>       git checkout -b dccp master
>
> 4. pull the experimental DCCP tree into this branch using
>       git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp.git dccp
>
>
> Alternative way:
> ----------------
> 1. clone the master branch
>       git clone  --reference davem-2.6  git://eden-feed.erg.abdn.ac.uk/dccp_exp
>
>    This will only give you `origin', which is taken from the David Miller tree.
>
> 2. Add (all important) the dccp tree:
>       git remote  add  dccp  git://eden-feed.erg.abdn.ac.uk/dccp_exp
>       git remote  show dccp
>
> 3. To track recent changes, do
>       git remote  update
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
