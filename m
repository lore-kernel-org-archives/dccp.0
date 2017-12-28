From: David Miller <davem@davemloft.net>
Date: Thu, 28 Dec 2017 17:06:13 +0000
Subject: Re: [PATCH net-next v6 0/6] net: tcp: sctp: dccp: Replace jprobe usage with trace events
Message-Id: <20171228.120613.1048334566479767343.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <151444140014.11331.17287122201510506083.stgit@devbox>
In-Reply-To: <151444140014.11331.17287122201510506083.stgit@devbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 28 Dec 2017 15:10:00 +0900

> Changes from v5:
>   [1/6]: Avoid preprocessor directives in tracepoint macro args

Patch #1 is not the only patch which has this problem, at a minimum
patch #5 has it too.

Please audit the entire series for an issue when it is brought to your
attention.

Thank you.
