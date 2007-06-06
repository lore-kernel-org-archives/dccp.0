From: Chuck Ebbert <cebbert@redhat.com>
Date: Wed, 06 Jun 2007 22:55:50 +0000
Subject: Re: [BUG] Fwd: segfault : modprobe dccp_probe/tcp_probe
Message-Id: <46673B76.2090508@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00706061347v42c9ecbahb5354f6687a70a78@mail.gmail.com>
In-Reply-To: <5640c7e00706061347v42c9ecbahb5354f6687a70a78@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 06/06/2007 04:47 PM, Ian McDonald wrote:
> Hi there,
> 
> We've seen a report of a problem with dccp_probe as shown below. The
> user has also verified that it occurs in tcp_probe as well. This is on
> Dave Miller's tree but that currently tracks Linus' tree quite
> closely. I do note that it is around 2.6.22-rc2 timeframe so there is
> a possibility fixes may have gone in since.
> 

It faulted when it tried to write the breakpoint instruction into the
running kernel's executable code. Apparently the kernel code is now marked
read-only?

