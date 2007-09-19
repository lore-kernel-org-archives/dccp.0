From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Wed, 19 Sep 2007 14:56:58 +0000
Subject: Re: CONFLICT using git-pull
Message-Id: <5bc4c4570709190756y4fbe5a71t9afaa7ca951e0d0c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
In-Reply-To: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/19, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> Leandro, -
>
> |  But when I type git-pull
> Warning: I don't know your configuration, but if you are checking out everything
> (which is fine), you will get the most recent netdev-tree. This is currently
> tracking davem-2.6.git (not davem-2.6.24.git, due to the troubles reported earlier).
>
> The first thing I'd ask you to try is to check out _only_ the DCCP tree:
>
>  1. use your normal tree
>  2. create a subtree dccp:
>
>         git branch -b dccp master
>
>  3. now pull the `dccp' subtree into your tree (as Ian also recommended)
>
>          git-pull git://eden-feed.erg.abdn.ac.uk/dccp_exp dccp
>
> If this still fails then there is a difference between your tree and the netdev-2.6 one
> which needs to be resolved.
>
> For such cases, I put up extracts from the DCCP patches online at
>
>         http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/
>
> HTH
> Gerrit
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Good clue Gerrit. I'll always try to follow your suggestions. Some
days ago we talked about the frequency that you sync your git tree
with dave git tree. You said that will define a specific frequency
(for instance, every week) that you will do this. Did you already
define it?

Leandro.

-- 
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager & Network Administrator
http://embedded.ufcg.edu.br/
+55 083 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
