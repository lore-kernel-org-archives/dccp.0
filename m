From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Apr 2018 14:42:20 +0000
Subject: Re: [PATCH] net: dccp: Replace GFP_ATOMIC with GFP_KERNEL in dccp_init
Message-Id: <8216dee8-5e52-421e-026a-4c75d654be54@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1523283004-25581-1-git-send-email-baijiaju1990@gmail.com>
In-Reply-To: <1523283004-25581-1-git-send-email-baijiaju1990@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On 04/09/2018 07:10 AM, Jia-Ju Bai wrote:
> dccp_init() is never called in atomic context.
> This function is only set as a parameter of module_init().
> 
> Despite never getting called from atomic context,
> dccp_init() calls __get_free_pages() with GFP_ATOMIC,
> which waits busily for allocation.

What do you mean by "waits busily" ?

GFP_ATOMIC does not sleep, does not wait.

> GFP_ATOMIC is not necessary and can be replaced with GFP_KERNEL,
> to avoid busy waiting and improve the possibility of sucessful allocation.
> 
> This is found by a static analysis tool named DCNS written by myself.
> And I also manually check it.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
> ---


