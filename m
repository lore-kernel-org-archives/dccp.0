From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 02 Jan 2008 02:37:53 +0000
Subject: Re: dccp send
Message-Id: <20080102023753.GG25000@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Jan 02, 2008 at 01:41:16AM +0100, Tomasz Grobelny escreveu:
> When I use dccp does sendmsg function block (until it sends the packet)? If 
> so, should it? In either case, how to make it just queue the packet and 
> return?

The interface is the same as for other AF_INET transports, use
O_NONBLOCK (open, fcntl) if you want it to be non blocking.

It queues it in the write routine and tries to send it right away, but
doesn't waits for actually sending the packet, i.e. it only checks if
there is write space available, if you set O_NONBLOCK and there is no
space it returns ENOBUFS, if O_NONBLOCK is not set it will sleep waiting
for write space to be made available, when the process will be awaken.

Use setsockopt(SO_SNDTIMEO) to change the default send timeout, etc.

- Arnaldo
