From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 22 Sep 2006 14:50:22 +0000
Subject: Re: [PATCH 2.6.19] net/dccp: set safe upper bound for option length
Message-Id: <39e6f6c70609220750i681a28c4lf912c7ccb393cd72@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: current upper limit for option length is 128 bytes;
> much less than actually possible. This patch sets a safe upper
> bound on option length of 992, under worst-case assumptions.
>
> This patches against the 2.6.19 tree by David.

Gerrit, could you please use my net-2.6.19? I'm going over the pending
dccp patches backlog and it is possible that this patch now doesn't
applies, haven't checked tho as I'm going out, will check in 20
minutes or so.

Ah, and please keep dccp@vger.kernel.org instead of netdev when the
patch is only dccp specific.

Thanks,

- Arnaldo
