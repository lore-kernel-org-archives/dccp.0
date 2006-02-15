From: Ian McDonald <imcdnzl@gmail.com>
Date: Wed, 15 Feb 2006 01:53:54 +0000
Subject: Re: [PATCH/RFC]: Re: Problem with feature negotiation
Message-Id: <cbec11ac0602141753sff04be1j69557bab17d0bf73@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70602140712k5579e1bfy2445f45e9c97f966@mail.gmail.com>
In-Reply-To: <39e6f6c70602140712k5579e1bfy2445f45e9c97f966@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Take a look at my tree, I guess its fixed now by setting the defaults according
> to the selection of CCIDs in the kernel config, i.e. if CCID2 is built
> it is the default,
> as the spec states, but if it isn't CCID3 becomes the default and an #error is
> spit if no CCID has been selected for compilation.
>
> Please test and report results, then I'll push for Dave to get it into 2.6.17
>
Tested just fine.

Signed-off-by: Ian McDonald <imcdnzl@gmail.com>
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
