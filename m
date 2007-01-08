From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Mon, 08 Jan 2007 17:48:25 +0000
Subject: Re: [SUMMARY]: Problems with loss interval recalculation / audit against [RFC 3448, 5.4]
Message-Id: <39e6f6c70701080948r4f197aa4wdb914b2b2d0eaea7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701051829.20415@strip-the-willow>
In-Reply-To: <200701051829.20415@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/8/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> Gerrit,
>
> First I would like to send a NEWBIE REQUEST.
>
> How can I get a complete copy of the DCCP source checked out, including
> your/Ian's patches?  Where is there something on line that explains the git
> process?  Thanks for your/anyone's help.

Git process:

Install git (if you have problems with this, let us know):

Then:

git-clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git

With this you should have David Miller networking tree, the canonical
one when working on linux networking code, mine is just a staging area
for David as his is a staging area for Linus.

At this point Gerrit is maintaining a set of patches, not using git,
so you'll have to get the patches he is staging for me at:

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/the_whole_lot.tar.gz

Apply them in order and you'll have the current status quo, I hope to
go over the patches Gerrit is graciously maintaining soon, but the
process above should be simple enough for you to follow.

Questions?

- Arnaldo
