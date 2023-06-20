From: David Ahern <dsahern@kernel.org>
Date: Tue, 20 Jun 2023 02:09:27 +0000
Subject: Re: [RFC PATCH v2 1/4] net: wire up support for file_operations->uring_cmd()
Message-Id: <d289ab2c-dd5a-fd35-2a2a-7ccdfb947873@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230614110757.3689731-2-leitao@debian.org>
In-Reply-To: <20230614110757.3689731-2-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/19/23 2:28 AM, Pavel Begunkov wrote:
> That callback is all about file dependent operations, just like ioctl.
> And as the patch in question is doing socket specific stuff, I think
> architecturally it fits well. I also believe Breno wants to extend it
> later to support more operations.
> 
> Sockets are a large chunk of use cases, it can be implemented as a
> separate io_uring request type if nothing else works, but in general
> that might not be as scalable.

The io_uring commands are wrappers to existing networking APIs - doing
via io_uring what userspace apps can do via system calls. As such, the
translations should be done in io_uring code and then invoking in-kernel
APIs.

Same comment applies to sockopts when those come around and any other
future extensions.
