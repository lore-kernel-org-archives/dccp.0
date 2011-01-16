From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 16 Jan 2011 17:15:27 +0000
Subject: Re: Sequence Number Validation Bug Fixes 0/2
Message-Id: <20110116171527.GA4746@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1293392426.3801.234.camel@jero-laptop>
In-Reply-To: <1293392426.3801.234.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Right now, I'm seeing speeds of 9.43Mbits/sec over a 10Mbit/sec link and
| 85Mbit/sec over a 100Mbit/sec link (TCP does 91Mbit/sec). Those speeds
| seem very reasonable and are much better than anything I have seen yet
| in working with DCCP. Is that about what I should expect to get out of
| DCCP? Or is it typical to get better performance than that?
| 
These tests are very encouraging and the results look really good.

If I recall correctly on similar tests there were not higher numbers. Have you
compared this with TCP on the same link (iperf)?

What can be expected is that CCID-3 will be comparatively slower (CCID-4 has a
fixed limit of about 1.15 Mbps).
