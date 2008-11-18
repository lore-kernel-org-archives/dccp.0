From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 18 Nov 2008 05:07:35 +0000
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Message-Id: <20081118050735.GB3846@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dave, -
| > Summing up, I have doubts that basing CCID-3 will bring advantages and
| > would much rather go the other way and (consistently) use lower resolution.
| > 
| > Thoughts?
| 
| I wouldn't bother with high resolution timers, mostly because they are more
| expensive and the benefit of them here is at best "unknown".
| 
Thanks a lot for the reply. I am glad for this suggestion, since it will
allow simpler code while at the same time still supporting a basic,
working implementation of CCID-3.

If people want to experiment with higher-resolution timers (as per other
replies), this can be put into an experimental subtree on 
eden-feed.erg.abdn.ac.uk.

If it is okay with Leandro and Tommi, it would finally also make it
possible to sort out consolidating the CCID-3/CCID-4 code.

Thanks again,
Gerrit
