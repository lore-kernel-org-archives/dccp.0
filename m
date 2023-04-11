From: Jens Axboe <axboe@kernel.dk>
Date: Tue, 11 Apr 2023 15:28:29 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <20cb4641-c765-e5ef-41cb-252be7721ce5@kernel.dk>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/11/23 9:24?AM, Willem de Bruijn wrote:
> Jens Axboe wrote:
>> On 4/11/23 9:00?AM, Willem de Bruijn wrote:
>>> Jens Axboe wrote:
>>>> On 4/11/23 8:51?AM, Willem de Bruijn wrote:
>>>>> Jens Axboe wrote:
>>>>>> On 4/11/23 8:36?AM, David Ahern wrote:
>>>>>>> On 4/11/23 6:00 AM, Breno Leitao wrote:
>>>>>>>> I am not sure if avoiding io_uring details in network code is possible.
>>>>>>>>
>>>>>>>> The "struct proto"->uring_cmd callback implementation (tcp_uring_cmd()
>>>>>>>> in the TCP case) could be somewhere else, such as in the io_uring/
>>>>>>>> directory, but, I think it might be cleaner if these implementations are
>>>>>>>> closer to function assignment (in the network subsystem).
>>>>>>>>
>>>>>>>> And this function (tcp_uring_cmd() for instance) is the one that I am
>>>>>>>> planning to map io_uring CMDs to ioctls. Such as SOCKET_URING_OP_SIOCINQ
>>>>>>>> -> SIOCINQ.
>>>>>>>>
>>>>>>>> Please let me know if you have any other idea in mind.
>>>>>>>
>>>>>>> I am not convinced that this io_uring_cmd is needed. This is one
>>>>>>> in-kernel subsystem calling into another, and there are APIs for that.
>>>>>>> All of this set is ioctl based and as Willem noted a little refactoring
>>>>>>> separates the get_user/put_user out so that in-kernel can call can be
>>>>>>> made with existing ops.
>>>>>>
>>>>>> How do you want to wire it up then? We can't use fops->unlocked_ioctl()
>>>>>> obviously, and we already have ->uring_cmd() for this purpose.
>>>>>
>>>>> Does this suggestion not work?
>>>>
>>>> Not sure I follow, what suggestion?
>>>>
>>>
>>> This quote from earlier in the thread:
>>>
>>> I was thinking just having sock_uring_cmd call sock->ops->ioctl, like
>>> sock_do_ioctl.
>>
>> But that doesn't work, because sock->ops->ioctl() assumes the arg is
>> memory in userspace. Or do you mean change all of the sock->ops->ioctl()
>> to pass in on-stack memory (or similar) and have it work with a kernel
>> address?
> 
> That was what I suggested indeed.
> 
> It's about as much code change as this patch series. But it avoids
> the code duplication.

Breno, want to tackle that as a prep patch first? Should make the
functional changes afterwards much more straightforward, and will allow
support for anything really.

-- 
Jens Axboe
