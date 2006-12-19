From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 19 Dec 2006 22:38:57 +0000
Subject: Re: [PATCH 5/8]: Move debugging macro to header file
Message-Id: <5640c7e00612191438o1341d65bvec80221e6f53660c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
In-Reply-To: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/20/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> > I think the right thing to do is not to introduce another level of debugging.
> >
> > People want to debug or they don't in my opinion. I think we should do
> > away with ccid3_pr_debug and ccid2_pr_debug. I always turn them all on
> > or all off when working with testing (or add my own statements in).
>
> If the way to go is a boolean, i.e. to debug or not to debug we have
> to remove ccid{2,3}_pr_debug and stick to using dccp_pr_debug
> everywhere, that would eliminate the loop as dccp.ko doesn't directly
> uses any code from dccp_ipv[4,6]. ccid[2, 3] or tfrc.
>
Agree and that's what I prefer.

> But I think that being able to debug just the dccp core, or just
> ccid3, or just tfrc is better.
>
I'll go with your choice on this one. In the interim I'll carry on
using dccp_pr_debug for tfrc debugging as short on time.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
