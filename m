From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 08 Jan 2007 20:36:17 +0000
Subject: Re: [SUMMARY]: Problems with loss interval recalculation / audit against [RFC 3448, 5.4]
Message-Id: <5640c7e00701081236p36361b78ufd7377aa648242b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701051829.20415@strip-the-willow>
In-Reply-To: <200701051829.20415@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 09/01/07, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 1/8/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> > Gerrit,
> >
> > First I would like to send a NEWBIE REQUEST.
> >
> > How can I get a complete copy of the DCCP source checked out, including
> > your/Ian's patches?  Where is there something on line that explains the git
> > process?  Thanks for your/anyone's help.
>
> Git process:
>
> Install git (if you have problems with this, let us know):
>
> Then:
>
> git-clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
>
> With this you should have David Miller networking tree, the canonical
> one when working on linux networking code, mine is just a staging area
> for David as his is a staging area for Linus.
>
> At this point Gerrit is maintaining a set of patches, not using git,
> so you'll have to get the patches he is staging for me at:
>
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/the_whole_lot.tar.gz
>
> Apply them in order and you'll have the current status quo, I hope to
> go over the patches Gerrit is graciously maintaining soon, but the
> process above should be simple enough for you to follow.
>
> Questions?
>
> - Arnaldo

If you're just wanting to test Arnaldo's advice is great. If you're
wanting to code for a bit longer and keep up to date I'd add to his
advice a bit.

What I'd advise at present is to clone off Linus' tree and then make a
copy of this off Dave M's tree if needed (at present it is not needed
as no outstanding DCCP patches). This is because you will have to keep
recloning Dave M's tree when he starts afresh off Linus' tree.

I would use a patch management tool such as stgit or quilt so you can
look at individual patches. I personally use stgit and I can type
something like "stg import -t -s ../gerrit/series" to pull in all
Gerrit's patches.

I've written a draft paper (more practical than academic) on this
process which can be found on my webpage. I also have put quite a few
notes up on my local LUG Wiki http://wlug.org.nz/KernelDevelopment

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
