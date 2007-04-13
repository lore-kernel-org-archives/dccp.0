From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 20:27:54 +0000
Subject: Re: Sensitivity of TFRC throughput equation wrt to changes of RTT
Message-Id: <200704132127.54939@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704131303.03072@strip-the-willow>
In-Reply-To: <200704131303.03072@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting David Miller:
|  From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  Date: Fri, 13 Apr 2007 13:03:02 +0100
|  
|  > RFC 3448 gives in section 8 the following alternative format
|  > of the throughput equation (which is directly responsible for
|  > the alllowed sending rate X):
|  > 
|  >               s
|  >       X =  --------
|  >            R * f(p)
|  > 
|  > This shows that the dependence is reciprocal. Thus using an RTT
|  > which differs by a factor of 10 to account for in-stack processing
|  > results an a throughput reduction of factor 10.
|  > 
|  > In other words, 90 Mbits/sec becomes 9 Mbits/sec.
|  
|  What I'd like to know in all this is why the RTT influences the
|  sending rate at all in such a manner.  Please teach me :)

I wished someone could tell me that. Ian is right, the formula is used
after the first loss, but the idea is that the sender `overshoots' and then
reduces after the first loss due to overestimating the bandwidth.

So it would try to see the pipe as 20Gbit, experience some loss, and then
reduce proportionally to RTT and f(p). 

We have more problems of the same nature as with using interface timestamps.

I am really not sure that CCID3 can be implemented well without a lot of
real-time and system load requirements - if you have any suggestions or
know of similar problem areas, input would be very welcome.

  
|  TCP doesn't have any of these problems, and we use incredibly coarse
|  timestamping for RTTs.  We get jiffies granularity at best, with many
|  in-stack delays, and we still send at full line rate over large RTTs.
