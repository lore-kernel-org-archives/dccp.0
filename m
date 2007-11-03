From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sat, 03 Nov 2007 13:38:18 +0000
Subject: Re: [RFC]: Removal of spinlocks/rw_locks in ccid3.c /
Message-Id: <20071103133817.GA3780@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200711031350.20405@strip-the-willow>
In-Reply-To: <200711031350.20405@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Nov 03, 2007 at 01:50:20PM +0000, Gerrit Renker escreveu:
> With regard to the previous patch 9/9 I wonder if it is possible to remove the Reader/Writer spinlock used 
> in the test tree in packet_history.c (field member @lock in struct tfrc_rx_hist). 
> 
> If the socket is protected by the socket lock, and the same backlog handler does not run concurrently, then
> the RX history rw_lock is redundant. I haven't changed anything, but am about to reformat the patches so that
> each of them compiles standalone, it is a good time to address this.
> 
> The point that I find confusing here is that several new cards (e.g. e1000) can have multiple TX/RX queues
> on the same card: I wonder whether that will make a difference to the DCCP sk backlog handler.
> 
> Comments?

I think that you are right, we can't process two packets at the same
time for the same socket, more locks than the socket lock are not needed
at all.

With regards to multiple tx/rx queues: same reasoning applies, multiple
packets are being received/sent, but per socket serialization happens at
l4.

- Arnaldo
