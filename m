From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 16 Jun 2007 14:41:06 +0000
Subject: Re: [PATCH 1/6]: Avoid accumulation of large send credit
Message-Id: <200706161541.06386@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091957.56966@strip-the-willow>
In-Reply-To: <200706091957.56966@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Agree with Gerrit's comments in patchset description that there is
|  still discussion around this. Still doing something is better than
|  doing nothing.
Also agree with what you are saying. This is really why I would like
to get the experimental test tree for DCCP/CCID3 started soon.

With the mechanism already in place, it is a trivial change to use
a different value. 

Kohler/Floyd currently suggest to use 1 RTT, which derives from the theory of TFRC. 

The value t_ipi derives from the way the packets are currently scheduled.

Neither value may be the last piece of wisdom - we need people testing
this and report their experience + suggestions.
