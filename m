From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 29 May 2007 03:10:55 +0000
Subject: Re: [PATCH 1/5] DCCP: Shift ccid3_li_hist
Message-Id: <5640c7e00705282010u49ca76d3w9bffe3f906151d28@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200705112236.36406.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200705112236.36406.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/29/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
>
> Please take a look my tree at:
>
> http://git.kernel.org/?p=linux/kernel/git/acme/net-2.6.git
>

Thanks Arnaldo - looks great. I think these are fine to go to Dave.

> I rewrote your patches to achieve the same result while keeping
> loss_interval.c CCID agnostic Please also take a look at how the
> patches go on paving the way for the next  ones, without having to
> make dccp_li_hist temporarily exported, etc.
>
> This tree has just some copyright and compiler warning fixes besides
> these csets, so if you agree on it just provide me the signed-off or
> acked by lines and I'll add those and republish the tree.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz> for all patches.

Now to go and look at more patches again as time permits.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
