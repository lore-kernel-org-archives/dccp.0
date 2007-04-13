From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 08:59:35 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <200704130959.35754@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Cool it Ian. 

I think you are interpreting something into the email I sent which is not in
there. This is exactly the kind of talk I was asking for and I am glad that 
Dave reviewed this.

Please read that email again. 

I am asking for fair technical review here and rather than calling me names you
could put some care into what you write.

If for instance you read the documentation accompanying that patch, there is a 
difference between 100 usec ... 1msec between skb_get_timestamp and taking the timestamp
in the CCID3 receiver. It all adds up.

With regard to hrtimers - no patch was ever submitted, for the same reason that you
are stating. But with the current schedule_timeout, the controllable limit is at about
12Mbits/sec when HZ00. Above that it is no longer controlled, let alone congestion-
controlled.


Quoting Ian McDonald:
|  I didn't know this time stamping was expensive but I knew the way we
|  were trying to optimise LAN is wrong. I say LAN because a few
|  microseconds or even milliseconds difference on a WAN link makes
|  bugger all difference in throughput. DCCP takes into account operating
|  system granularity etc and if we are running lossless (i.e. receiver
|  can cope with receiving link at full speed) then we can transmit at
|  line speed. I've tested this myself.
|  
|  This illustrates a trend by you Gerrit to try and micro-optimise what
|  you perceive as bottlenecks and not realise the impact. You have been
|  also promoting possible use of hrtimers which would be even worse for
|  example in far of terms of loading a system.
| 
|  Gerrit - you send us a missive on how we should humbly accept your
|  patches and stop arguing with you. Obviously Eddie (co-author of DCCP
|  spec) and myself (converted DCCP CCID3 to Linux 2.6) aren't good
|  enough. Maybe now Dave Miller says something you will listen or do you
|  need Linus Torvalds to tell you to stop being a fucking idiot at
|  times? Yes you write lots of good code but you write some bad code at
|  times also. I probably write more bad code than you and less volume of
|  code but I try to listen. Stop pretending to be a deity.
|  
