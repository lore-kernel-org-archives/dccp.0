From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 11:33:51 +0000
Subject: Re: DCCP support in VLC
Message-Id: <200709281233.51892@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709271930.03854.rdenis@simphalempin.com>
In-Reply-To: <200709271930.03854.rdenis@simphalempin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Quoting Rémi Denis-Courmont:
|  > |  I am having a few API problems now:
|  > |
|  > |  First, TCP-like non-blocking connect() error handling does not seem to
|  > | work properly (2.6.22). I don't know if this is an intended difference
|  > | from TCP. VLC follows a pretty typical non-blocking connect flow:
|  > |
|  > |  socket()
|  > |  fcntl(F_SETFL, O_NONBLOCK)
|  > |  connect() = -1 (errno = EINPROGRESS)
|  > |  poll(POLLOUT) = 1
|  > |  getsockopt(SOL_SOCKET, SO_ERROR) = 0 (val = ECONNREFUSED)
|  > |
|  > |  Alas with DCCP, getsockopt returns 0 instead of ECONNREFUSED, even
|  > | though tcpdump reports a reset packet on the wire. And then VLC thinks
|  > | the connection succeeded, and well, tries to read from the socket...
<snip>
|  But your other kernel patch solved that now :-)
Thanks, this is good to know, but the patch that I sent you privately is not in a 
submittable state; I will tidy that up and resubmit it to the list.


|  So so, now I have yet another API problem :-$ When the peer shutdowns/closes 
|  the connection, recv() returns 0 (as with TCP). When the peer sends a 
|  zero-byte payload datagram, recv() also seems to return 0 (as with UDP).
|  How do I differentiate? With TCP and UDP, this is unambiguous because UDP has 
|  no such thing as shutdown, and TCP has no framing, so no empty payloads at 
|  application-layer.
It seems you are trying to use length=0 as End-Of-File? Works in TCP since it is
byte-stream, but DCCP is between UDP and TCP, so an empty frame is a valid pay-`load'.

When the Reset closing the connection arrives, the same shutdown mask is set as in TCP.
What I thus think you could do as a test-for-end-of-connection is to test whether the
socket descriptor is still read/writeable. 

Arnaldo, Ian - do you have suggestions?

A note on shutdown: this also works as in TCP. When you know that you will be using
the connection only in one direction, calling shutdown() for the unused direction  has 
distinct advantages, since it will mean that the CCID-halves which are not participating 
in the traffic will be bypassed, which improves the performance.
