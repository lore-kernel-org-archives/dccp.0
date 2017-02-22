From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Wed, 22 Feb 2017 09:35:20 +0000
Subject: Re: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Message-Id: <ce0ad8f1-f0df-0853-92ce-7dbb22c94698@virtuozzo.com>
List-Id: <dccp.vger.kernel.org>
References: <20170221112740.661-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170221112740.661-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 02/21/2017 09:24 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 21 Feb 2017 13:23:51 -0500 (EST)
> 
>> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Date: Tue, 21 Feb 2017 14:27:40 +0300
>>
>>> DCCP doesn't purge timewait sockets on network namespace shutdown.
>>> So, after net namespace destroyed we could still have an active timer
>>> which will trigger use after free in tw_timer_handler():
>>  ...
>>> Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
>>> timewait sockets on net namespace destruction and prevent above issue.
>>>
>>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>
>> Applied and queued up for -stable, thanks.
> 
> Actually, this doesn't even compile.  Please fix this up and resubmit:
> 

Right, I tested this on top of the Linus' tree. Rebased on -next now.
