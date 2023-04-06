From: Jens Axboe <axboe@kernel.dk>
Date: Thu, 06 Apr 2023 16:49:09 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <99c064d2-652a-8e3c-eacb-23cb46b3e3a6@kernel.dk>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/6/23 10:41?AM, Keith Busch wrote:
> On Thu, Apr 06, 2023 at 07:43:26AM -0700, Breno Leitao wrote:
>> This patchset creates the initial plumbing for a io_uring command for
>> sockets.
>>
>> For now, create two uring commands for sockets, SOCKET_URING_OP_SIOCOUTQ
>> and SOCKET_URING_OP_SIOCINQ. They are similar to ioctl operations
>> SIOCOUTQ and SIOCINQ. In fact, the code on the protocol side itself is
>> heavily based on the ioctl operations.
> 
> Do you have asynchronous operations in mind for a future patch? The
> io_uring command infrastructure makes more sense for operations that
> return EIOCBQUEUED, otherwise it doesn't have much benefit over ioctl.

Basically nothing returns EIOCBQUEUED, it's mostly sync/poll driven on
the networking side. The primary use case for this is with direct
descriptors, as you can't do get/setsockopt with those. And that means
you'd then need to instantiate a regular descriptor first and then
register it, rather than keep it all direct from the start.

-- 
Jens Axboe
