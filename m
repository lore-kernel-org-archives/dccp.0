From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 16 Jun 2007 17:11:02 +0000
Subject: Re: [PATCH 3/3]: Update computation of X to use newer timeofday interface
Message-Id: <200706161811.02609@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091933.09514@strip-the-willow>
In-Reply-To: <200706091933.09514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  OK, but doing the simple ktime_to_timeval above I was able to merge
|  something that moves us further, its clear and self contained, so I
|  loved it and merged.
Oh, sorry - I think I misunderstood you. Yes, of course, I was talking
experimental tree and didn't exactly know what you were working on.

And I fully trust that the results will be good. I will be back with
an update and as soon as the patch set is complete, I will bring it up
in the experimental tree. 

As in a recent email exchange with Ian, I believe that in the future
this will be much easier.

And if you have ideas or suggestions where patches could better be cut,
I'd be happy to take them on board.

