From: Jens Axboe <axboe@kernel.dk>
Date: Tue, 11 Apr 2023 15:06:45 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <19c69021-dce3-1a4a-00eb-920d1f404cfc@kernel.dk>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/11/23 9:00?AM, Willem de Bruijn wrote:
> Jens Axboe wrote:
>> On 4/11/23 8:51?AM, Willem de Bruijn wrote:
>>> Jens Axboe wrote:
>>>> On 4/11/23 8:36?AM, David Ahern wrote:
>>>>> On 4/11/23 6:00 AM, Breno Leitao wrote:
>>>>>> I am not sure if avoiding io_uring details in network code is possible.
>>>>>>
>>>>>> The "struct proto"->uring_cmd callback implementation (tcp_uring_cmd()
>>>>>> in the TCP case) could be somewhere else, such as in the io_uring/
>>>>>> directory, but, I think it might be cleaner if these implementations are
>>>>>> closer to function assignment (in the network subsystem).
>>>>>>
>>>>>> And this function (tcp_uring_cmd() for instance) is the one that I am
>>>>>> planning to map io_uring CMDs to ioctls. Such as SOCKET_URING_OP_SIOCINQ
>>>>>> -> SIOCINQ.
>>>>>>
>>>>>> Please let me know if you have any other idea in mind.
>>>>>
>>>>> I am not convinced that this io_uring_cmd is needed. This is one
>>>>> in-kernel subsystem calling into another, and there are APIs for that.
>>>>> All of this set is ioctl based and as Willem noted a little refactoring
>>>>> separates the get_user/put_user out so that in-kernel can call can be
>>>>> made with existing ops.
>>>>
>>>> How do you want to wire it up then? We can't use fops->unlocked_ioctl()
>>>> obviously, and we already have ->uring_cmd() for this purpose.
>>>
>>> Does this suggestion not work?
>>
>> Not sure I follow, what suggestion?
>>
> 
> This quote from earlier in the thread:
> 
> I was thinking just having sock_uring_cmd call sock->ops->ioctl, like
> sock_do_ioctl.

But that doesn't work, because sock->ops->ioctl() assumes the arg is
memory in userspace. Or do you mean change all of the sock->ops->ioctl()
to pass in on-stack memory (or similar) and have it work with a kernel
address?

>>>> I do think the right thing to do is have a common helper that returns
>>>> whatever value you want (or sets it), and split the ioctl parts into a
>>>> wrapper around that that simply copies in/out as needed. Then
>>>> ->uring_cmd() could call that, or you could some exported function that
>>>> does supports that.
>>>>
>>>> This works for the basic cases, though I do suspect we'll want to go
>>>> down the ->uring_cmd() at some point for more advanced cases or cases
>>>> that cannot sanely be done in an ioctl fashion.
>>>
>>> Right now the two examples are ioctls that return an integer. Do you 
>>> already have other calls in mind? That would help estimate whether
>>> ->uring_cmd() indeed will be needed and we might as well do it now.
>>
>> Right, it's a proof of concept. But we'd want to support anything that
>> setsockopt/getsockopt would do. This is necessary so that direct
>> descriptors (eg ones that describe a struct file that isn't in the
>> process file table or have a regular fd) can be used for anything that a
>> regular file can. Beyond that, perhaps various things necessary for
>> efficient zero copy rx.
>>
>> I do think we can make the ->uring_cmd() hookup a bit more palatable in
>> terms of API. It really should be just a sub-opcode and then arguments
>> to support that. The grunt of the work is really refactoring the ioctl
>> and set/getsockopt bits so that they can be called in-kernel rather than
>> assuming copy in/out is needed. Once that is done, the actual uring_cmd
>> hookup should be simple and trivial.
> 
> That sounds like what I proposed above. That suggestion was only for
> the narrow case where ioctls return an integer. The general approach
> has to handle any put_user.

Right

> Though my initial skim of TCP, UDP and RAW did not bring up any other
> forms.
> 
> getsockopt indeed has plenty of examples, such as receive zerocopy.

-- 
Jens Axboe
