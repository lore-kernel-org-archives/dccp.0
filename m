From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 13 Dec 2005 13:07:21 +0000
Subject: Re: [PATCH 3/3] DCCP: fix connect() race condition upon short connections
Message-Id: <39e6f6c70512130507t5069e6cs38f5e85cac73f2f4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20051213093402.GC8532@tribal.sorbonet.org>
In-Reply-To: <20051213093402.GC8532@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/13/05, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> The connect system call will initiate a connection, poll whether the connection
> has occured and right before returning, it will check whether the connection was
> shut-down.  In such cases, it will return -1.  If a connection is really short,
> it is possible that the connection occurs and terminates before connect()
> returns.  Upon checking that the connection is closed, connect() will
> incorrectly return -1 when the transfer did occur.
>
> I was able to reproduce this race condition consistently by having a server send
> 3 packets upon connection and disconnect right after.  I believe this issue
> might exist in TCP too although mitigated by the higher number of CLOSE states.
>
> I believe there is a better solution than the one I proposed [simplest I could
> think of].

Yes, I believe we should take a look at one that doesn't involves
tasklets, will try to come up with something today, but anyway, thanks
for pointing out the issue (again)!

- Arnaldo
