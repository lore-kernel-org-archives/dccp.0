From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 10:20:08 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <200704131120.08748@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  Well I would have much rather discussed in private but a) you've told
|  Eddie not to reply in public and the way stated seems to imply I            
                         ^--- u mean `private' ?
|  shouldn't either b) you said that we were unreasonably holding up your
|  patches in public. It warranted a response but I'm done with my name
|  calling (for now).
If it helps to let off steam ... I am not bearing any grudges. It is good to
vent anger (as Metallica would have us believe). The converse is unhealthy
(as Karl A. Menninger `Man against himself' makes clear).

With regards to offline discussions - yes, please, I would indeed much rather 
have them out in the open.


|  > If for instance you read the documentation accompanying that patch, there is a
|  > difference between 100 usec ... 1msec between skb_get_timestamp and taking the timestamp
|  > in the CCID3 receiver. It all adds up.
|  >
|  I think we need to look at whether the protocol is right for LANs but
|  I think if we carry out Eddie's suggestions it may well be right.
|  Against earlier code a couple of months ago with a couple of my
|  patches I was achieving around 90 Mbits/sec on iperf which matched TCP
|  performance and it was stable. It responded gracefully to loss also.
I have two boxes with Gbit cards here and saw speeds up to 750..820 Mbit.
It seems that the computation overhead allows it to reach up to 80..90% of the
link bandwidth (with coarse-granularity problems still unresolved).

  
|  I have not tested lately and tried to replicate but I know that the
|  state of tree before current patches couldn't do that any more... As
|  time permits I will redo the work.
Do you remember when the `bidirectional' patch was reverted? - after that the 
CCID3 sender slowed down again to 75..80 Mbits/sec on a 100Mbit link.
This comes from the processing overhead, and was the original motivation for 
this patch. 

That incidentally was the second `moronic' patch I had submitted (as it limited
connections to being one-directional). Without Andre's help it would probably still 
be in. This really is the point I was trying to make in the email - I think we need to
focus more on the code. Here are two cases where the missing review/input came from outside.

I am not claiming to be any special. My hacking skills are rather moderate (i.e. you
have been warned about them patches :)
  
Thanks.
