From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Mar 2008 11:13:06 +0000
Subject: Re: packet priorities
Message-Id: <20080308111306.GB4843@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| >  The deadline is not that easy to determine due to client side buffering. At
| >  least that would require cooperation on receiving side. For now I just assume
| >  that some packets are simply more important than others. That is they convey
| >  more information to the one who is watching. When streaming football match
| >  you are probably less interested in voice comments, music and applause and
| >  more about "where is the ball?" (video more important). But when watching the
| >  news usually audio is much more important than the object on video that
| >  you've already seen thousands of times.
| 
| You can track the rtt and also mark the expiry time and do the maths.
As per other email, I am interested in supporting the expiry time, with
the following sketch:

 * value is a simple unsigned which sets the expiry time relative to the
   time that the packet is submitted by the application;
 * millisecond or 10-millisecond granularity probably fully sufficient
   (would allow to use jiffy calculations);
 * reusing Ian's struct concept and the priority field:
   - if priority = 0, don't interpret any of the special fields;
   - if priority = 1, discard packet if too old;
   - rest is for further research/discussion.

Andre Noll, who maintains the paraslash streamer (with DCCP support)
further suggested a setsockopt() option to set the tx_qlen on a
per-socket basis, so that the size of the TX queue can be adapted.
