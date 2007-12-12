From: Burak Gorkemli <burakgmail-jvt@yahoo.com>
Date: Wed, 12 Dec 2007 20:40:57 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <402454.43276.qm@web30005.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> 
> | The scenario that I mostly use is limiting the bandwidth with a
> 
 middlebox running TBF. However, all of the recent trees 
> | except 2.6.20final_dccp (2.6.20 patched with Ian's
> modifications)
> 
 that I have tested fail to achieve acceptable transfer rates. 
> Thank you for the report, but the material as-is does not help us
> very much. What is missing is the link speed of the
> ethernet cards that lead to the middlebox, and have you monitored
> the 
 loss rate p? 
> Using a TBF in this setting means slowing down the link speed by
> a 
 factor of 10 .. 20, and unless you are using large
> FIFOs in addition to the TBF, the loss rate will very soon reach
> high 
 values.
> 

Link speed is 100 Mbps, and I tested DCCP under various bottleneck
bandwidths, like 1000, 2000, 5000 and 10000 Mbps. I will repeat the
tests with dccp_probe enabled, and show the results in a website,
as soon as I have time.

> Therefore, can you please clarify what you mean by "acceptable
> transfer 
 rates": maybe the scenario is not supposed to
> warrant any high transfer rates at all. Which would mean
> expecting 
 something where not much can be expected - as said,
> without more detailed knowledge about how p reacts, these figures
> don't 
 tell us very much.
> 

By acceptable transfer rates I was referring to the rates achieved
by 2.6.20final_dccp. But you are right, we cannot be sure of
the goodness of the results by comparing two DCCP stacks,
so I am giving TCP-Reno streaming results below under same 
conditions, which should be a solid benchmark:

Bottleneck00Kbps:    0.0-60.6 sec    6.91 MBytes   958
 Kbits/sec
Bottleneck 00Kbps:    0.0-60.1 sec    13.7 MBytes  1.91 Mbits/sec

BottleneckP00Kbps:    0.0-60.1 sec    33.6 MBytes  4.69 Mbits/sec

Bottleneck000Kbps,limitP000bytes:    0.0-60.1 sec    65.4 MBytes   9.13 Mbits/sec

The average transfer rates in the rightmost column show that
the configured bottleneck rates are achievable, hence I think
the transfer rates that 2.6.20final_dccp reaches seem acceptable,
whereas the rates of other trees are not.



> Didn't you have a web page with further information?

I will have soon, hopefully.

>
> Yes, please: the cleanest comparison would be to take a 2.6.24
> tree, 
 and compare the patch sets on the same basis. I almost expected that the
> results are not as good as the 2.6.20final_dccp -- it is an almost
> sure 
 indication that the difference is not due to the patches, and that
> there are other factors at work. By carefully looking at
> these 
 differences, we will be able to see clearer what is happening in the above.
> 

I agree with you. 2 or 3 weeks ago I applied Ian's patches to

more recent trees (2.6.22 and 2.6.24) and the results were

not as good as 2.6.20.


> Again thanks a lot for posting results, hope you will be back with
> further information soon,
> 
> Gerrit
> 

I am planning to repeat the tests focusing on 2.6.24 and
post the results - with dccp_probe figures in my website.

Burak

