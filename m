From: Jia-Ju Bai <baijiaju1990@gmail.com>
Date: Mon, 09 Apr 2018 14:46:05 +0000
Subject: Re: [PATCH] net: dccp: Replace GFP_ATOMIC with GFP_KERNEL in dccp_init
Message-Id: <ab55c4a7-ee67-eead-eeeb-4dc92eaf9aee@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1523283004-25581-1-git-send-email-baijiaju1990@gmail.com>
In-Reply-To: <1523283004-25581-1-git-send-email-baijiaju1990@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On 2018/4/9 22:42, Eric Dumazet wrote:
>
> On 04/09/2018 07:10 AM, Jia-Ju Bai wrote:
>> dccp_init() is never called in atomic context.
>> This function is only set as a parameter of module_init().
>>
>> Despite never getting called from atomic context,
>> dccp_init() calls __get_free_pages() with GFP_ATOMIC,
>> which waits busily for allocation.
> What do you mean by "waits busily" ?
>
> GFP_ATOMIC does not sleep, does not wait.

Sorry, I should modify it to "does not sleep".
Do you think it is okay?


Best wishes,
Jia-Ju Bai
