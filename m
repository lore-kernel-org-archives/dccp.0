From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 17 Jul 2007 15:43:22 +0000
Subject: Re: [PATCH 0/10]: Support for passive close
Message-Id: <200707171643.22607@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200707121520.48349@strip-the-willow>
In-Reply-To: <200707121520.48349@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian,


|  > The receiver of a CloseReq or Close packet is asked to subsequently close its end of the 
|  > connection, and to acknowledge connection termination by sending a Close or Reset 
|  > packet, respectively (RFC 4340, 8.3). Before sending such confirmation, the receiver of a
|  > connection-termination request needs to have a chance to process yet-unread data of its
|  > receive queue. Otherwise, immediately following through with a connection-termination
|  > request has the same effect as an abortive release of the connection: unread data is
|  > discarded, leading to unexpected API behaviour.
|  
|  Agree totally with this part. Data has to be read.
|  
|  > For example, it was observed in the Linux implementation that immediately replying with a
|  > Close to a CloseReq has the undesirable consequence of removing all unread data
|  > whenever the Reset answering the Close arrived too early; data was sent to the receiver
|  > (and could be captured on the wire), but the receiver never got a chance to read it.
|  
|  And herein lies the problem. But I have, possible, another solution in mind.
|  - receive CloseReq from server
|  - client sends Close immediately (without putting at tail of queue)
|  - server sends Reset
|  - client receives Reset but does NOT tear down connection immediately
|  because as per Section 5.6 of RFC4340 there is a reset code. If this
|  is code 1 then it is a normal connection close
|  - client processes all packets in receive queue
|  - client tears down connection
This contains two different questions
 1. how not to tear down state immediately (and I can see agreement in your answer that this is needed);
 2. how to handle the defined DCCP Reset codes.
The difficulty that I see with the above solution regarding (1) is that part of the processing
goes through user space: in the above we only drain the queues and enter timewait after the user
application has called dccp_recvmsg. If the user application gets suspended for a long time or
even crashes, how to time out the state for the socket or enter timewait?

|  
|  > Therefore, Close and CloseReq packets should be enqueued in the receive queue so that
|  > required confirmation of connection-termination is produced after all previously-received
|  > data has been processed.
|  
|  The other cases where client sends close don't matter as if client is
|  sending close it should be ready to die.
|  
|  With your solution the server has to keep track of state longer as it
|  is waiting for a userspace program to read all packets before
|  acknowledging closereq. For a server with many short lived flows this
|  could be significant.
But this criticises not my solution, it is criticising the fact that a state name CLOSEREQ exists.
The server only enters this state via an active-close, ie. by calling close() on the socket; ie.
there won't be any reads by a userspace program; from the server's point of view the connection is
dead at that time. (But it may decide to keep the timewait state.)


|  I suspect the method I outline would be a relatively simple fix to the
|  existing code but I haven't looked at it yet.
Maybe, but the proof of concept is missing. I initially also thought that it would be simple to 
fix, but when doing such things one has the obligation to do it in such a way that it does not
introduce new side affects and acts consistently with all other combinations of state transitions.

That is why the patch set may seem more complex, since I had to sit down and check each of the
state transitions. The internal PASSIVE_1/2 states are not visible outside, thus the signalling
behaviour to the peer is conformant with DCCP signalling. 


  
|  Please note your method works perfectly fine and is an acceptable fix,
|  and can go in. My method may not even work as I'm thinking out loud
|  here really.
This really is appreciated since by looking at the same thing one often gets better ideas,
please see below.

I am defending my solution on the grounds that I have verified the possible state transitions, 
most signalling is in the kernel, and changes are documented. 

The main point behind this patch set is the API: with regard to closing states one now gets
the same behaviour as with TCP, i.e. the close() calls work as expected - either when called
directly, or implicitly via exit(). 

So what I mainly take home from your email is that it would be good to look at how DCCP reset
codes are passed on to the user interface. At an initial glance, it seems that something SO_ERROR
(as in socket(7)) could do this.

The second thing is a related issue and for this work has not been done: it would be good to tackle
the following problem. Like other transport protocols, DCCP also supports shutdown(2). But it is
not internally supported, and I can see benefits in two directions:
 (a) make the socket API consistent with other transport protocols;
 (b) reduce a lot of unwanted processing. Always going through both RX/TX half-connections
     for each received packet is a lot of CPU cycles. If a sender knows it is only sending,
     it could issue a shutdown(SHUT_RD) and we could block reception of packets for the
     RX half connection (as the receive end is closed). 
     I think this would allow significant savings.
 (c) Since DCCP does not support half-close, I suspect that shutdown(SHUT_RD|SHUT_WR) should
     best be aliased to close()

Input on these issues is also welcome - I had started work on this directly after this passive-close
patch set, but not had time to continue yet.
