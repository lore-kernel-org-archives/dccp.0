From: gerrit@erg.abdn.ac.uk
Date: Mon, 21 Apr 2008 14:03:50 +0000
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Message-Id: <1538.84.55.217.198.1208786630.squirrel@84.55.217.198>
List-Id: <dccp.vger.kernel.org>
References: <20080421.023503.242108516.davem@davemloft.net>
In-Reply-To: <20080421.023503.242108516.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Mon, 21 Apr 2008 16:22:27 +0900 (JST)
>
>> What do_gettimeofday() does is to call getnstimeofday() and
>> to convert the result from timespec{} to timeval{}.
>> We do not always need timeval{} and we can convert timespec{}
>> when we really need (to print).
>>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>
> This looks good too, but I'll be polite and wait for any
> DCCP maintainer ACKs :-)
>
This mirrors a patch which is currently in the test tree and does the
update to timespec, apart from a few other changes. It is a good idea,
since that in turn mirrors tcp_probe.c
Hope Arnado will in some future have time to look at some of the test tree
patches, in any case this patch does not harm.



The University of Aberdeen is a charity registered in Scotland, No SC013683.

