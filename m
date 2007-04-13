From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 10:38:15 +0000
Subject: Re: [PATCH 08/29] Honour initial RTT estimate
Message-Id: <200704131138.15229@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070412211505.GI21292@ghostprotocols.net>
In-Reply-To: <20070412211505.GI21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > This is a small optimisation which improves the accuracy of TX
|  > RTT sampling when an initial RTT sample (e.g. from the intial
|  > Request/Response exchange) is available.
<snip>
|  
|  Ok, even more...
|  
|  I'm not pulling this stuff in, you guys have to work out a way
|  to implement this without killing performance on the rest of
|  the system.
|  
I take it you are referring to the moved skb_get_timestamp in this patch?

As part of of reverting the RX/TX timestamp patches, this will go back
to either dccp_gettimestamp() or do_gettimeofday() (will discuss with Arnaldo)
- as will be all other patches that depend on the RX/TX timestamps.

When that is removed, I'd say that this patch is useful since it increases
the number of samples used to average the RTT.

I will post a summary of all changes to the list.
