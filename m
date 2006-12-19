From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 19 Dec 2006 22:14:17 +0000
Subject: Re: [PATCH 5/8]: Move debugging macro to header file
Message-Id: <5640c7e00612191414x331c0ff1nc33718af1065789b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
In-Reply-To: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/20/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> The loop comes because dccp_ccid3.ko needs symbols provided by
> dccp_tfrc_lib.ko, so if we try to export ccid3_pr_debug to be used by
> dccp_tfrc_lib.ko we'll get the loop, so I guess the right thing to do
> is to introduce tfrc_pr_debug, that will give us more flexibility,
> allowing one to select ccid3 debugging, tfrc debugging, both or none.
>
> - Arnaldo
>
I think the right thing to do is not to introduce another level of debugging.

People want to debug or they don't in my opinion. I think we should do
away with ccid3_pr_debug and ccid2_pr_debug. I always turn them all on
or all off when working with testing (or add my own statements in).

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
