From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 30 Jul 2008 12:02:43 +0000
Subject: Re: [PATCH 5/7] dccp tfrc: Increase number of RTT samples
Message-Id: <20080730120243.GA4961@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1217325952-12337-6-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1217325952-12337-6-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > The effectiveness of using suboptimal samples (with a delta between 1 and 4) was
| > confirmed by instrumenting the algorithm with counters. The results of two 20
| > second test runs were:
| >  * With the old algorithm and a total of 38442 function calls, only 394 of these
| >   calls resulted in usable RTT samples (about 1%), 378 out of these were
| >   "perfect" samples, and 28013 (unused) samples had a delta of 1..3.
| >  * With the new algorithm and a total of 37057 function calls, 1702 usable RTT
| >   samples were retrieved (about 4.6%), 5 out of these were "perfect" samples.
| > This means an almost five-fold increase in the number of samples.
| >
| 
| Great work. This should make a real improvement.
| 
Unfortunately it does not change some of the conceptual problems. When
the sender is sending at a rate of less than one packet per RTT then it
can happen that there are no usable RTT samples for a long while.

MP3 streaming is an example, and there are other audio/voice streaming
formats which also do not need to send more than one packet per RTT.

In one case of MP3 streaming there was not a single usable RTT estimate
over the course of almost 1-2 hours (found via printk to syslot).
What happens if meanwhile the link properties change?

I am not at all happy with this algorithm, it is probably as good as it
can get, but it won't help if the sending rate is low.
