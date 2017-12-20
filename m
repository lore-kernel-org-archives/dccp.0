From: David Miller <davem@davemloft.net>
Date: Wed, 20 Dec 2017 19:20:40 +0000
Subject: Re: [PATCH net-next v4 0/6] net: tcp: sctp: dccp: Replace jprobe usage with trace events
Message-Id: <20171220.142040.593760128783699712.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <151374325126.2497.6934744693865165386.stgit@devbox>
In-Reply-To: <151374325126.2497.6934744693865165386.stgit@devbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Wed, 20 Dec 2017 13:14:11 +0900

> This series is v4 of the replacement of jprobe usage with trace
> events. This version is rebased on net-next, fixes a build warning
> and moves a temporal variable definition in a block.
> 
> Previous version is here;
> https://lkml.org/lkml/2017/12/19/153
> 
> Changes from v3:
>   All: Rebased on net-next
>   [3/6]: fixes a build warning for i386 by casting pointer unsigned
>         long instead of __u64, and moves a temporal variable
>          definition in a block.

Looks good, series applied to net-next, thanks.

