From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 26 Jul 2006 08:48:11 +0000
Subject: Re: Help: how to get the latest code?
Message-Id: <5640c7e00607260148s7806b4bds953ac00024dbc067@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
In-Reply-To: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/26/06, Ma Lin <gavin.malin@gmail.com> wrote:
> Andrea,
> How can I apply your patches at http://darkircop.org/dccp/ to my local
> DCCP code?
> I have a copy of kernel 2.6.17-1 on PC, the code is not downloaded by
> git, so there is no git repository.
> Sorry, if the question is too stupid, relly too novice :)
> Also, thanks to Ian for the previous answer.
>
> malin

For most patches save to a text file, change into the top level of
your source code tree and then type:
patch -p1 < patchname

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
