From: David Miller <davem@davemloft.net>
Date: Tue, 02 Jan 2018 19:28:29 +0000
Subject: Re: [PATCH net-next v7 0/6] net: tcp: sctp: dccp: Replace jprobe usage with trace events
Message-Id: <20180102.142829.460646209771343186.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 29 Dec 2017 11:45:20 +0900

> This series is v7 of the replacement of jprobe usage with trace
> events. This version fixes net/dccp/trace.h to avoid sparse
> warning. Since the TP_STORE_ADDR_PORTS macro can be shared
> with trace/events/tcp.h, it also introduce a new common header
> file and move the definition of that macro.
> 
> Previous version is here;
>  https://lkml.org/lkml/2017/12/28/7
> 
> Changes from v6:
>   [5/6]: Avoid preprocessor directives in tracepoint macro args

Series applied, thank you.
