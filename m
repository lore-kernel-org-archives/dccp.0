From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Wed, 19 Sep 2007 14:49:48 +0000
Subject: Re: Source repository for CCID 4
Message-Id: <5bc4c4570709190749m367a280ay2f862f0152c7f4fa@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070919081635.GA26986@kikai.katei.fi>
In-Reply-To: <20070919081635.GA26986@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Tommi,

   Good! I just arrived at the university and generated what I current
have for CCID-4. It still a initial code for CCID-4 based on CCID-3
implementation. As we agree (me, you and Ian), you sent your code and
I'm send the mine now.

   http://embedded.ufcg.edu.br/~leandro/dccp/ccid4/gerritgit-net-dccp-ccid4-19_09.diff

   In this address one can download the diff file done against the
latest gerrit git tree. As I said it is a initial code and currently
I'm identifying similar codes between CCID-3 and CCID-4 in order to
avoid duplication of code and put them into a common lib, probably in
ccids/lib
   I have also other ideas, such as create a .txt documentation
describing the steps of how to create new ccids and/or make use of the
current ccids code. Another particular idea is trying to create a kind
of ccids manager, which will be responsible to automatically identify
new ccids files into net/dccp/ccids/ written in a specify way (to be
defined and documented in the .txt file) and automatically change some
codes such as the include/linux/dccp.h, Kconfigs, etc. For sure, this
is not the priority and the idea needs to be improved.
   Futhermore, currently I'm also study the draft and ccid-3 rfc for
go into the ccid-4 implementation.
   About the signed-off-by and acked-by, I also don't know its usage,
but if I understood right, it is a kind of signal of agreement or not
for something. For me, it is still a little bit confused. Please,
someone to explain us this issue?


2007/9/19, Tommi Saviranta <wnd@iki.fi>:
> After discussing the topic on IRC, we figured we need a place to have
> the sources for CCID 4 available for everyone. This way we can finally
> start cooperating on it.
>
> I have created a few patches against dccp-exp. Even if they're not much,
> or pretty, they may be something to start with.
>
> Complete patch can be found at
>         http://wnd.katei.fi/dccp/files/ccid4_2007-09-19.diff
>
> The sources are based on ~a week old copy of CCID 3 from dccp-exp,
> created with
>         http://wnd.katei.fi/dccp/files/copy-ccid3-to-ccid4.sh
>
> There also exists a patch against created ccid4.[ch] (without necessary
> changes to include/linux/dccp.h, net/dccp/ccids/Kconfig, and
> net/dccp/ccids/Makefile) at
>         http://wnd.katei.fi/dccp/files/ccid4.c.h_2007-09-19.diff
>
>
> And what exactly is the deal, or convention, with Signed-off-by at
> dccp-exp?
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager & Network Administrator
http://embedded.ufcg.edu.br/
+55 083 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
