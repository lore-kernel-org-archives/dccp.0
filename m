From: David Ahern <dsahern@kernel.org>
Date: Tue, 11 Apr 2023 14:36:50 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <75e3c434-eb8b-66e5-5768-ca0f906979a1@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/11/23 6:00 AM, Breno Leitao wrote:
> I am not sure if avoiding io_uring details in network code is possible.
> 
> The "struct proto"->uring_cmd callback implementation (tcp_uring_cmd()
> in the TCP case) could be somewhere else, such as in the io_uring/
> directory, but, I think it might be cleaner if these implementations are
> closer to function assignment (in the network subsystem).
> 
> And this function (tcp_uring_cmd() for instance) is the one that I am
> planning to map io_uring CMDs to ioctls. Such as SOCKET_URING_OP_SIOCINQ
> -> SIOCINQ.
> 
> Please let me know if you have any other idea in mind.

I am not convinced that this io_uring_cmd is needed. This is one
in-kernel subsystem calling into another, and there are APIs for that.
All of this set is ioctl based and as Willem noted a little refactoring
separates the get_user/put_user out so that in-kernel can call can be
made with existing ops.
