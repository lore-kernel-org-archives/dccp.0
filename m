From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 13:08:03 +0000
Subject: Re: [PATCH 0/5] CCID 4: initial implementation of CCID 4
Message-Id: <5bc4c4570709200608u50eec0dfw3714f1dcd5eac904@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920111557.GA1288@kikai.katei.fi>
In-Reply-To: <20070920111557.GA1288@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/20, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> |  Re-submitting, with hopefully proper tags etc.
> |
> |
> |  After discussing the topic on IRC, we figured we need a place to have
> |  the sources for CCID 4 available for everyone. This way we can finally
> |  start cooperating on it.
> |
> The patches applied fine, a new subtree `ccid4' has been created to host these.
> The subtree can be checked out by
>
>         1) create a subtree
>
>                 git-checkout -b ccid4 master
>
>         2) pull the CCID4 subtree
>
>                 pull  eden-feed:/usr/src/GIT/dccp_exp.git ccid4
>
>
> This tree now sits on top of the test tree, i.e. inherits it. As said, I am ok
> tracking changes required to ensure that patches remain applicable.
>
> What I can't do is to track updates to CCID3 into your code, since that would mean
> altering your patches; so it is something you need to keep track of yourselves.
>
> Gerrit
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

I think that update ccid4 according to ccid-3 will not be a problem.

Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager & Network Administrator
http://embedded.ufcg.edu.br/
+55 083 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
