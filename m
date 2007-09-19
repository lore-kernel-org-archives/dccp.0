From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Wed, 19 Sep 2007 14:53:50 +0000
Subject: Re: CONFLICT using git-pull
Message-Id: <5bc4c4570709190753x3a2775dbsad3963b7d6664755@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
In-Reply-To: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/19, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> On 9/19/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> > Hi,
> >    as for the implementation of CCID-4, I modified some files of the
> > gerrit git during last week and weekend and now I but to make a fetch
> > of te gerrit latest code. But when I type git-pull I'm getting the
> > following:
> >
>
> From past experience the tree has been rebased so you'll have to
> reclone the tree and then reapply your patches. It's too hard to fix
> (or I'm too dumb!!)
>
> I keep at least two trees - one is Linus' pure one and one (or more)
> are my development trees.
>
> Then when git-pull fails you reclone based from Linus tree and it
> saves time and bandwidth.
>
> This is documented at:
> http://linux-net.osdl.org/index.php/DCCP_Testing#How_to_obtain
>
> Feel free to ask more questions.
>
> Ian
> --
> Web1: http://wand.net.nz/~iam4/
> Web2: http://www.jandi.co.nz
> Blog: http://iansblog.jandi.co.nz
>

Thank you! I followed your recommendation. I already had the gerrit
tree for some experimental usage and for study the code and develop
some patches, such as ccid-4. I don't know what happened that cause
this conflicts. In all the case, I already rebase and clone the tree.

Leandro.

-- 
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager & Network Administrator
http://embedded.ufcg.edu.br/
+55 083 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
