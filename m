From: Keith Busch <kbusch@kernel.org>
Date: Thu, 06 Apr 2023 16:41:52 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <ZC72UKx/sA4syPfK@kbusch-mbp.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Apr 06, 2023 at 07:43:26AM -0700, Breno Leitao wrote:
> This patchset creates the initial plumbing for a io_uring command for
> sockets.
> 
> For now, create two uring commands for sockets, SOCKET_URING_OP_SIOCOUTQ
> and SOCKET_URING_OP_SIOCINQ. They are similar to ioctl operations
> SIOCOUTQ and SIOCINQ. In fact, the code on the protocol side itself is
> heavily based on the ioctl operations.

Do you have asynchronous operations in mind for a future patch? The io_uring
command infrastructure makes more sense for operations that return EIOCBQUEUED,
otherwise it doesn't have much benefit over ioctl.
 
> In order to test this code, I created a liburing test, which is
> currently located at [1], and I will create a pull request once we are
> good with this patch.
> 
> I've also run test/io_uring_passthrough to make sure the first patch
> didn't regressed the NVME passthrough path.
> 
> This patchset is a RFC for two different reasons:
>   * It changes slighlty on how IO uring command operates. I.e, we are
>     now passing the whole SQE to the io_uring_cmd callback (instead of
>     an opaque buffer). This seems to be more palatable instead of
>     creating some custom structure just to fit small parameters, as in
>     SOCKET_URING_OP_SIOC{IN,OUT}Q. Is this OK?

I think I'm missing something from this series. Where is the io_uring_cmd
change to point to the sqe?
