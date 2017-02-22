From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Wed, 22 Feb 2017 08:59:03 +0000
Subject: Re: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Message-Id: <6b21534b-060d-9eac-53f1-7fb3ec448358@virtuozzo.com>
List-Id: <dccp.vger.kernel.org>
References: <20170221112740.661-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170221112740.661-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 02/21/2017 04:43 PM, Arnaldo Carvalho de Melo wrote:
> Em Tue, Feb 21, 2017 at 02:27:40PM +0300, Andrey Ryabinin escreveu:
>> DCCP doesn't purge timewait sockets on network namespace shutdown.
>> So, after net namespace destroyed we could still have an active timer
>> which will trigger use after free in tw_timer_handler():
>>
>>
>> Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
>> timewait sockets on net namespace destruction and prevent above issue.
> 
> Please add this, to help stable kernels to pick this up
> 
> Fixes: b099ce2602d8 ("net: Batch inet_twsk_purge")
> Cc: Eric W. Biederman <ebiederm@xmission.com> 
> 

Fixes tag should blame commit f2bf415cfed7 ("mib: add net to NET_ADD_STATS_BH").
It introduced use of net namespace in the timer callback.
