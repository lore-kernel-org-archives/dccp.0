From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 05 Feb 2011 13:58:42 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <20110205135842.GB4752@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Leandro,
| >  include/net/tcp.h      |   12 +++---------
| >  net/dccp/ccids/ccid2.c |    9 +++++++++
|
David's change only affects CCID-2, CCID-3/4 remain unaffected,
they use rfc3390_initial_rate() (which does almost the same).
 
|     I don't think this change will make sense for DCCP, once IW10 is
| for the cases of short-lived flows. DCCP is used on scenarios for
| multimedia flows, which are, in general, long-lived flows. So, IMO the
| way how we calculate IW for DCCP is appropriate, at least considering
| a quick answer. 
I agree with you, and also vote to eventually bring CCID-2 on a par with
the state of art in TCP. Before we can do this, the CCID-2 implementation
needs some work (as per separate thread with Samuel Jero).

| In fact, nowadays we need better congestion control algorithms for DCCP,
| and in this sense we are working on adapt TCP Cubic for DCCP as a CCID,
| and also we started some work to make DCCP support TCP pluggable
| mechanism , which will allow us to use TCP congestion control
| algorithms in DCCP.
This is very good news and am very much looking forward to the new approach.


| DCCP should calculate its IW as specified in RFC3390 rather than set
| it to IW10. For the moment, I understand that for DCCP, we have to 
| discuss more about this in a separated thread.
Agree that we should keep an eye on this - perhaps too early to turn it into a
should. Networking speeds are growing, and many of the simulations were based
on TCP Reno which stems from the 10 Mbit ethernet era.
