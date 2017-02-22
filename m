From: David Miller <davem@davemloft.net>
Date: Wed, 22 Feb 2017 21:15:38 +0000
Subject: Re: [PATCH v2] net/dccp: fix use after free in tw_timer_handler()
Message-Id: <20170222.161538.2214724719402158538.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20170222093527.19698-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170222093527.19698-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Wed, 22 Feb 2017 12:35:27 +0300

> DCCP doesn't purge timewait sockets on network namespace shutdown.
> So, after net namespace destroyed we could still have an active timer
> which will trigger use after free in tw_timer_handler():
 ...
> Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
> timewait sockets on net namespace destruction and prevent above issue.
> 
> Fixes: f2bf415cfed7 ("mib: add net to NET_ADD_STATS_BH")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied and queued up for -sable, thanks.
