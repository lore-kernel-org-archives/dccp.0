From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 06 Nov 2008 15:21:02 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: Ignore packets with specific priority
Message-Id: <20081106152102.GB3621@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200810262233.54649.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200810262233.54649.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| What about using select() call to get the effect of waiting? I think that 
| select() is precisely designed for such a thing. It is generally used on 
| reading from sockets so it could be used on writing to sockets as well. I 
| haven't looked at the code yet to know how complicated it might be to 
| implement but it seems to be a nice idea to consider.
| 
I think select() will give us similar problems - it is this very old BSD socket
interface. 

To me Posix asynchronous I/O seems to be a highly promising idea here, since it is
possible to submit a packet and then have the kernel call you back to confirm
that it has been dispatched.

I don't know the full state of AIO, it recently popped up in a configuration
menu,  http://lse.sourceforge.net/io/aio.html
