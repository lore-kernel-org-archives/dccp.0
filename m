From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 09:27:16 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <200704131027.16739@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorry, I misread the email. Please see below.

|  You want the scheduling delays and other issues that can
|  delay DCCP input packet processing to get factored into
|  the RTT, so that the sender will pace properly.
|  
|  Trying to get perfect timestamping and RTT measurements,
|  and ignoring scheduling delays, is quite foolhardy and shows
|  a lack of understanding of how queueing really works.
CCID3 uses the sampled RTT value as input into an equation so any
inaccuracies will multiply. I observed a difference of about 10.

Currently the performance of CCID3 severely sucks and I tried every 
bit to make it better. Obviously this is not the right way.

Your comments are helpful, thank you. 

I will revert all RX/TX timestamps and I think there is no need to
take the timestamp in the dccp receive input function. 

By taking the timestamp in the CCID3 handler, it will include all 
processing overhead, slowing the sending rate further down in proportion 
to that difference.
