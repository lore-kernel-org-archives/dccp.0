From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 10 Jan 2007 10:21:38 +0000
Subject: Re:  [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <200701101021.38920@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

		Packet scheduling tardiness problem
		-----------------------------------

I would like to continue discussion on your patch; I hope you are not dismayed
about the response: this concerned only the code changes as such. I think that
there is a valid point which you were trying to resolve.

I have therefore consulted with colleagues and tried to find out why successive
packets might be too late. This resulted in the following.

(A) The granularity of the rate-based packet scheduling is too coarse

    We are resolving t_ipi with microsecond granularity but the timing for the
    delay between packets uses millisecond granularity (schedule_timeout). This
    means we can only generate inter-packet delays in the range of 1 millisecond
    up to 15.625 milliseconds (the largest possible inter-packet interval which
    corresponds to 1 byte per each 64 seconds). 

    As a result, our range of speeds that can be influenced is:

	    1/64 byte per second  ....  1000 bytes per second

    In all other cases, the delay will be 0 (due to integer division) and hence
    their packet spacing solely depends on how fast the hardware can cope.

    In essence, this is like a car whose accelerator works really well in the
    range 1 meter/hour up to 2 miles per hour, and for everything else it tries
    to use top speed of 120 mph. 

    Therefore I wonder if there is some kind of `micro/nanosleep' which we can use?
    Did some grepping and inevitably landed in kernel/hrtimers.c - any advice on
    how to best deploy these?
    
    On healthy links the inter-packet times are often in the range of multiples of
    10 microseconds (60 microseconds is frequent). 


(B) Fixing send time for packets which are too late
    
    You were mentioning bursts of packets which appear to be too late. I consulted
    with a colleague of how to fix this: the solution seems much more complicated
    than the current infrastructure supports.
    Suppose the TX queue length is n and the packet at the head of the queue is too
    late. Then one would need to recompute the sending times for each packet in the
    TX queue by taking into account the tardiness (it would not be sufficient to
    simply drain the queue). It seems that we would need to implement a type of
    credit-based system (e.g. like a Token Bucket Filter); in effect a kind of Qdisc
    on layer 4.

When using only a single t_nom for the next-packet-to-send as we are doing at the moment,
resetting t_nom to t_now when packets are late seems the most sensible thing to do. 

So what I think we should do is fix the packet scheduling algorithm to use finer-grained
delay. Since in practice no one really is interested in speeds of 1kbyte/sec and below,
it in effect means that we are not controlling packet spacing at all.
