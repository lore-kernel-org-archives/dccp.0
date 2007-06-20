From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 20 Jun 2007 04:19:14 +0000
Subject: Re: [PATCH 0/1]: Current BUGs
Message-Id: <5640c7e00706192119hac0340eu2a7c360b8f50f1ba@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706191129.55105@strip-the-willow>
In-Reply-To: <200706191129.55105@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/20/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  > 1. Write queue not empty
> |  > ------------------------
> |  > |   "KERNEL: assertion (skb_queue_empty(&sk->sk_write_queue))
> |  > |  failed at net/core/stream.c (276)" in system log.
> |  > I observed this also at some time - but with TCP.
> |
I've also seen this but presumed it was my own research code (which is
far from perfect). Maybe it's not and I should look at more...

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
