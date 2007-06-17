From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 11:05:50 +0000
Subject: Re: [PATCH 3/6]: Ignore trivial amounts of elapsed time
Message-Id: <200706171205.50441@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091958.18116@strip-the-willow>
In-Reply-To: <200706091958.18116@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 6/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [CCID3]: Ignore trivial amounts of elapsed time
|  >
|  > This patch fixes a previously undiscovered bug:
|  >
|  >  * the receive timestamp is taken when the skb enters the CCID3 module;
|  >  * RFC 4342 requires to send an Elapsed Time estimate to the sender;
|  >  * the bug is in computing the elapsed time as the time between `receiving'
|  >    the packet (i.e. skb enters CCID module) and sending feedback,
|  >      --> there is no layer-processing, queueing, or delay involved,
|  >      --> hence the elapsed time is in the order of 1 function call
|  >      --> this is in the dimension of maximally 50..100usec
|  >      --> which renders the use of elapsed time almost entirely useless.
|  >
|  > The fix is simply to ignore such trivial amounts of elapsed time.
|  >
|  What is the bug? Do you mean it is useless to do this? Or is there
|  another problem?
Yes I mean it is useless. The discussions with David Miller after the interface
timestamping patches have convinced me that RTT sample values of less than 500
microseconds are not worth the overhead. And if you remember, you said something
similar. And here I agree with you.

The above also agrees with observation - in logs the most frequent ELAPSED_TIME
I found was 1 = 1 * 10 microseconds, which makes sense with regard to the above.


|  
|  Reading RFC4340, 13.2 and thinking about pre-emptible kernels causes
|  me to ask this question - what happens if you lose the time slice you
|  are on in between the calls - then it would be much higher time
|  difference....
|  
The processing all happens in softirq context and the flow of function calls
is in the processing path of the handler. 
The only way I can see that we will get a delay is in the case when skb allocation
fails in dccp_send_ack. This is something to be considered, but this (memory allocation
failture) seems to be an exception-case, not a rule-case. Hence it is implicitly added
to the processing/RTT delay of the host. To me this seems right: if the host is struggling
to get memory for skbs, it doesn't seem `right' to indicate to the other side that
the elapsed time = time to find an unallocated skb is negligible.
Thoughts?
