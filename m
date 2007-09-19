From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 19 Sep 2007 03:34:49 +0000
Subject: Re: CONFLICT using git-pull
Message-Id: <5640c7e00709182034w49fd5170v8d1163c01616312e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
In-Reply-To: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/19/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> Hi,
>    as for the implementation of CCID-4, I modified some files of the
> gerrit git during last week and weekend and now I but to make a fetch
> of te gerrit latest code. But when I type git-pull I'm getting the
> following:
>

From past experience the tree has been rebased so you'll have to
reclone the tree and then reapply your patches. It's too hard to fix
(or I'm too dumb!!)

I keep at least two trees - one is Linus' pure one and one (or more)
are my development trees.

Then when git-pull fails you reclone based from Linus tree and it
saves time and bandwidth.

This is documented at:
http://linux-net.osdl.org/index.php/DCCP_Testing#How_to_obtain

Feel free to ask more questions.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
