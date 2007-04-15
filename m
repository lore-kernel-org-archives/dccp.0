From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 15 Apr 2007 16:15:32 +0000
Subject: Re: Sensitivity of TFRC throughput equation wrt to changes of RTT
Message-Id: <200704151715.32852@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704131303.03072@strip-the-willow>
In-Reply-To: <200704131303.03072@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Many thanks indeed for the input - referred to in the other 
email as well.
  
|  So my primary suggstion is to accept that there is a limit to
|  how accurate you can get timestamps, there is also a specific
|  regime under which fine-RTT measurements matter, and therefore
|  the algorithm chosen has to match that reality.
|  
I think that by building on such realities we stand a better chance
of arriving at a workable solution than by blindly trying to cast
a specification into code.

There is some revision to be done where your input is very helpful. 

I hope that Eddie will incorporate/pick up the point to bypass the congestion
control when RTTs are low. 

Ian and Eddie seem to have differing opinions regarding RTT accuracy
and I think I also need to check. ( If only we could use jiffie-based algorithm, 
that would axe the cost of all these gettimeofdays (they still exist, even 
after retracting the skb_get_timestamp patches). There is this really nice TCP
algorithm which doesn't use timestamps, tcp_rcv_rtt_update() in tcp_input.c . )
