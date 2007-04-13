From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 09:51:47 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <200704131051.47373@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting David Miller:
|  > CCID3 uses the sampled RTT value as input into an equation so any
|  > inaccuracies will multiply. I observed a difference of about 10.
|  
|  This would indicate a bug in the equation if such small variances
|  cause it to explode so easily.
|  
|  RTTs modulate constantly, that's why they are smoothed out (at least
|  in TCP), to kill the noise and figure out what part of the signal
|  is real :-)
|  
|  > By taking the timestamp in the CCID3 handler, it will include all
|  > processing overhead, slowing the sending rate further down in
|  > proportion to that difference.
|  
|  Sarcastic much? :-/
Yeah maybe - it is not always easy to admit being wrong. But even so,
I am glad for your comments; all skb_timestamping operations will be
reverted without exception.

Thanks again.

