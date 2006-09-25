From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Sep 2006 09:03:39 +0000
Subject: Re: CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <200609251003.39649@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609210930.21903@strip-the-willow>
In-Reply-To: <200609210930.21903@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  >  1/ TX Buffering: set size of TX ring buffer via socket option.
|  
|  The size of the TX buffer is interesting in applications which want to do their
|  own queue management.  That is, real-time applications that would prefer
|  dropping certain packets and re-order other packets based on the state of the
|  session.  We are used to the standard UNIX "push" model where you shove stuff in
|  the kernel via write.  Perhaps a different architecture would be for the TX
|  buffer to be in user-land and the kernel to pull from it.  There is a lot of
|  overhead [context-switch] added, but there might be a good way of coding this.
|  By doing so, the application chooses exactly what to send and when.  Perhaps
|  this is equivalent to a 0 TX buffer size.
|  
|  Alternatively, there could be an API for managing the TX buffer in the kernel,
|  or maybe tagging packets with an expiry time or something.  The bottom line is,
|  that other than just regulating the TX buffer size, there might be smarter
|  things that we could do and may turn out to be useful.  Giving the application
|  the power to control what is sent and when, in accordance with the CCID, will
|  allow the application to make use of all of DCCP's benefits.

I went through Lai's paper again and read Ian's code: no need to go into user-space,
thanks to Ian's efforts, the same packet ring principle is already in the kernel. 

Things that would be good to work on (imho) are:

  * Notification Mechanism Between CCID <=> Main Module
    The Lai implementation used a hybrid polling / asynchronous notification principle,
    which involved setting a flag and using a syscall. The mechanism you suggested 
    earlier sounds very interesting - if you have any patches, could you make them 
    available via your website please?
 
  * Setting Size of TX Buffer 
    This relates to the second paragraph above. There are simulations which show that
    the size of the TX queue (currently infinite) influences the packet drop rate. 
    For further work, it would be good to set an upper limit on qlen. 
    As you say, with qlen = 0, one could disable in-kernel buffering if desired.
    Wouldn't it then be that dcccp_sendmsg() either blocks or returns -EAGAIN
    if the write_queue's qlen is > maximal value  (special case for 0).


Gerrit
