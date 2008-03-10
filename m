From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Mar 2008 14:47:02 +0000
Subject: Re: packet priorities
Message-Id: <20080310144702.GD7984@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > >  The deadline is not that easy to determine due to client side buffering.
<snip>
| >
| > You can track the rtt and also mark the expiry time and do the maths.
| > Again check my papers...
| I think we don't understand each other well here. My point is that no matter 
| what the kernel does it cannot always know whether packet will be late or 
| not. That is because it would need feedback from client how much of the 
| stream is buffered. Suppose that RTT is 10ms but the client code buffered 15 
| seconds of transmission. If the packet was waiting in DCCP send queue for 5 
| seconds should we send it or discard? Without feedback from the player we 
| cannot tell.
| In some applications it is possible to assume some sensible defaults or 
| negotiate delay. But that is not a priority for me for now. But of course the 
| design should allow specifying deadline.
| -- 
I find the same problem here, and it gets even worse when the client
side uses different buffer sizes for pre-buffering. And the RTT can also
change.

Hence in my understanding only the simplest form of specifying a deadline
makes sense -- giving an upper bound on the playout time. And this can be
done by the application. Servers such as Darwin Streaming Server also take
application-layer RTTs, so that the kernel need not spend extra cycles on
doing timestamping.
