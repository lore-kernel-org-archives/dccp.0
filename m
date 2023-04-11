From: Jens Axboe <axboe@kernel.dk>
Date: Tue, 11 Apr 2023 14:41:15 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <67831406-8d2f-feff-f56b-d0f002a95d96@kernel.dk>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/11/23 8:36?AM, David Ahern wrote:
> On 4/11/23 6:00 AM, Breno Leitao wrote:
>> I am not sure if avoiding io_uring details in network code is possible.
>>
>> The "struct proto"->uring_cmd callback implementation (tcp_uring_cmd()
>> in the TCP case) could be somewhere else, such as in the io_uring/
>> directory, but, I think it might be cleaner if these implementations are
>> closer to function assignment (in the network subsystem).
>>
>> And this function (tcp_uring_cmd() for instance) is the one that I am
>> planning to map io_uring CMDs to ioctls. Such as SOCKET_URING_OP_SIOCINQ
>> -> SIOCINQ.
>>
>> Please let me know if you have any other idea in mind.
> 
> I am not convinced that this io_uring_cmd is needed. This is one
> in-kernel subsystem calling into another, and there are APIs for that.
> All of this set is ioctl based and as Willem noted a little refactoring
> separates the get_user/put_user out so that in-kernel can call can be
> made with existing ops.

How do you want to wire it up then? We can't use fops->unlocked_ioctl()
obviously, and we already have ->uring_cmd() for this purpose.

I do think the right thing to do is have a common helper that returns
whatever value you want (or sets it), and split the ioctl parts into a
wrapper around that that simply copies in/out as needed. Then
->uring_cmd() could call that, or you could some exported function that
does supports that.

This works for the basic cases, though I do suspect we'll want to go
down the ->uring_cmd() at some point for more advanced cases or cases
that cannot sanely be done in an ioctl fashion.

-- 
Jens Axboe
