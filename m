From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 12:11:32 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <200704131311.32404@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

 |  > Do you remember when the `bidirectional' patch was reverted? - after that the
|  > CCID3 sender slowed down again to 75..80 Mbits/sec on a 100Mbit link.
|  > This comes from the processing overhead, and was the original motivation for
|  > this patch.
|  
|  How many connections? Up to now, when I was more involved in DCCP
|  development, for the sake of testing the correctness of the protocol I
|  mostly tested with just a few connections, most of the time with just
|  one, which is OK while we're not yet feeling so good about the overal
|  correctness of the implementation, and because I mostly reused the TCP
|  machinery, but for performance we really have to test with many
|  connections, and in fact in combination with TCP connections, so that
|  we can see how DCCP affects overal system performance/stability.
This was a single connection, the results that one gets with iperf in byte-blast mode.
I am reasonably positive that this is due to processing overhead and actually have a
concept how to fix this - by not delivering to the RX CCID when a node has set SHUT_RD.
The application can do this via shutdown() when it knows that it is not going to need
any data and will only send (e.g. a streaming audio server).

<snip>
|  but in the end I pushed for Dave trying to move things a bit forward, my bad, we really
|  have to take into account decisions we make that affects the rest of
|  the system :-\
I am sorry for the delay that this has caused, I much appreciate the support in getting
the patches worked through.
