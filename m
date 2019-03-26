From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 26 Mar 2019 01:21:09 +0000
Subject: Re: [BACKPORT 4.4.y 18/25] tcp/dccp: drop SYN packets if accept queue is full
Message-Id: <20190326012109.GD29420@kroah.com>
List-Id: <dccp.vger.kernel.org>
References: <20190322154425.3852517-19-arnd@arndb.de>
In-Reply-To: <20190322154425.3852517-19-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Mar 22, 2019 at 04:44:09PM +0100, Arnd Bergmann wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Per listen(fd, backlog) rules, there is really no point accepting a SYN,
> sending a SYNACK, and dropping the following ACK packet if accept queue
> is full, because application is not draining accept queue fast enough.
> 
> This behavior is fooling TCP clients that believe they established a
> flow, while there is nothing at server side. They might then send about
> 10 MSS (if using IW10) that will be dropped anyway while server is under
> stress.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> (cherry picked from commit 5ea8ea2cb7f1d0db15762c9b0bb9e7330425a071)

Also queued up for 4.9.y
