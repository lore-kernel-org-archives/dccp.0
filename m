From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Sat, 14 Apr 2007 05:43:46 +0000
Subject: Re: Sensitivity of TFRC throughput equation wrt to changes of RTT
Message-Id: <46206A12.2030208@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200704131303.03072@strip-the-willow>
In-Reply-To: <200704131303.03072@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I can't resist:

David Miller wrote:
>> I am really not sure that CCID3 can be implemented well without a lot of
>> real-time and system load requirements - if you have any suggestions or
>> know of similar problem areas, input would be very welcome.
> 
> I wonder what a DCCP implementation on old BSD would do with it's
> super-coarse timers :-)

Such a DCCP would do exactly what several people have suggested tens of times 
by now, namely send in bursts... which would be fine.  (Or at least better.)

Eddie
