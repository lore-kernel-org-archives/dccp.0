From: Breno Leitao <leitao@debian.org>
Date: Thu, 06 Apr 2023 16:58:40 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <ZC76QH97yFsx9e7y@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello Keith,

On Thu, Apr 06, 2023 at 10:41:52AM -0600, Keith Busch wrote:
> On Thu, Apr 06, 2023 at 07:43:26AM -0700, Breno Leitao wrote:
> > This patchset creates the initial plumbing for a io_uring command for
> > sockets.
> > 
> > For now, create two uring commands for sockets, SOCKET_URING_OP_SIOCOUTQ
> > and SOCKET_URING_OP_SIOCINQ. They are similar to ioctl operations
> > SIOCOUTQ and SIOCINQ. In fact, the code on the protocol side itself is
> > heavily based on the ioctl operations.
> 
> Do you have asynchronous operations in mind for a future patch? The io_uring
> command infrastructure makes more sense for operations that return EIOCBQUEUED,
> otherwise it doesn't have much benefit over ioctl.

I think this brings value even for synchronos operations, such as, you
can just keep using io_uring operations on network operations, other
than, using some io_uring operations and then doing a regular ioctl(2).
So, it improves the user experience.

The other benefit is calling several operations at a single io_uring
submit. It means you can save several syscalls and getting the same work
done.

>  
> > In order to test this code, I created a liburing test, which is
> > currently located at [1], and I will create a pull request once we are
> > good with this patch.
> > 
> > I've also run test/io_uring_passthrough to make sure the first patch
> > didn't regressed the NVME passthrough path.
> > 
> > This patchset is a RFC for two different reasons:
> >   * It changes slighlty on how IO uring command operates. I.e, we are
> >     now passing the whole SQE to the io_uring_cmd callback (instead of
> >     an opaque buffer). This seems to be more palatable instead of
> >     creating some custom structure just to fit small parameters, as in
> >     SOCKET_URING_OP_SIOC{IN,OUT}Q. Is this OK?
> 
> I think I'm missing something from this series. Where is the io_uring_cmd
> change to point to the sqe?

My bad, the patch was not part of the patchset. I've just submitted it
under the same RFC cover letter now.

Here is the link, if it helps:

https://lkml.org/lkml/2023/4/6/990

