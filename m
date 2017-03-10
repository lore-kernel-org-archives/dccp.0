From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Mar 2017 04:23:44 +0000
Subject: Re: [PATCH net, v1] dccp/tcp: fix routing redirect race
Message-Id: <1489119824.28631.26.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
References: <1489116691-26264-1-git-send-email-jmaxwell37@gmail.com>
In-Reply-To: <1489116691-26264-1-git-send-email-jmaxwell37@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, 2017-03-10 at 14:31 +1100, Jon Maxwell wrote:
> As Eric Dumazet pointed out this also needs to be fixed in IPv6.
> v1: Contains the IPv6 patch as well.

> Fixes: ceb3320610d6 ("ipv4: Kill routes during PMTU/redirect updates.")
> Cc: Eric Garver <egarver@redhat.com>
> Cc: Hannes Sowa <hsowa@redhat.com>
> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
> ---
>  net/dccp/ipv4.c     | 3 ++-
>  net/ipv4/tcp_ipv4.c | 3 ++-
>  net/ipv6/tcp_ipv6.c | 8 +++++---

Hi Jon.

You forgot net/dccp/ipv6.c 

dccp_v6_err() has the same issue.


