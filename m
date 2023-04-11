From: Jens Axboe <axboe@kernel.dk>
Date: Tue, 11 Apr 2023 15:17:52 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <b56c03b3-d948-2fdf-bc5d-635ecfdf1592@kernel.dk>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/11/23 9:10?AM, David Ahern wrote:
> On 4/11/23 8:41 AM, Jens Axboe wrote:
>> On 4/11/23 8:36?AM, David Ahern wrote:
>>> On 4/11/23 6:00 AM, Breno Leitao wrote:
>>>> I am not sure if avoiding io_uring details in network code is possible.
>>>>
>>>> The "struct proto"->uring_cmd callback implementation (tcp_uring_cmd()
>>>> in the TCP case) could be somewhere else, such as in the io_uring/
>>>> directory, but, I think it might be cleaner if these implementations are
>>>> closer to function assignment (in the network subsystem).
>>>>
>>>> And this function (tcp_uring_cmd() for instance) is the one that I am
>>>> planning to map io_uring CMDs to ioctls. Such as SOCKET_URING_OP_SIOCINQ
>>>> -> SIOCINQ.
>>>>
>>>> Please let me know if you have any other idea in mind.
>>>
>>> I am not convinced that this io_uring_cmd is needed. This is one
>>> in-kernel subsystem calling into another, and there are APIs for that.
>>> All of this set is ioctl based and as Willem noted a little refactoring
>>> separates the get_user/put_user out so that in-kernel can call can be
>>> made with existing ops.
>>
>> How do you want to wire it up then? We can't use fops->unlocked_ioctl()
>> obviously, and we already have ->uring_cmd() for this purpose.
>>
>> I do think the right thing to do is have a common helper that returns
>> whatever value you want (or sets it), and split the ioctl parts into a
>> wrapper around that that simply copies in/out as needed. Then
>> ->uring_cmd() could call that, or you could some exported function that
>> does supports that.
>>
>> This works for the basic cases, though I do suspect we'll want to go
>> down the ->uring_cmd() at some point for more advanced cases or cases
>> that cannot sanely be done in an ioctl fashion.
>>
> 
> My meta point is that there are uapis today to return this information
> to applications (and I suspect this is just the start of more networking
> changes - both data retrieval and adjusting settings). io_uring is
> wanting to do this on behalf of the application without a syscall. That
> makes io_uring yet another subsystem / component managing a socket. Any
> change to the networking stack required by io_uring should be usable by
> all other in-kernel socket owners or managers. ie., there is no reason
> for io_uring specific code here.

I think we are in violent agreement here, what I'm describing is exactly
that - it'd make ioctl/{set,get}sockopt call into the same helpers that
->uring_cmd() would, with the only difference being that the former
would need copy in/out and the latter would not.

But let me just stress that for direct descriptors, we cannot currently
call ioctl or set/getsockopt. This means we have to instantiate a
regular descriptor first, do those things, then register it to never use
the regular file descriptor again. That's wasteful, and this is what we
want to enable (direct use of ioctl set/getsockopt WITHOUT a normal file
descriptor). It's not just for "oh it'd be handy to also do this from
io_uring" even if that would be a worthwhile goal in itself.

-- 
Jens Axboe
