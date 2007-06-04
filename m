From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Jun 2007 13:00:14 +0000
Subject: Re: [PATCH 0/3] DCCP: Minor changes
Message-Id: <200706041400.15074@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706041149.01701.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200706041149.01701.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  Following on from Arnaldo's merging of my earlier patches and his rewrite
|  of some others I've gone back over my original series and rewritten/checked
|  and these three still need merging.
|  
|  Also found at http://wand.net.nz/~iam4/dccp/patches22/ as patches 11, 12, 13.
|  
Ian, 

can you please finalise and send all outstanding patches, so as to get a complete picture.
I see that the net-2.6.23 tree is not out yet, so it would be better to do this now. 
There is some overlap with my patch set, but I will need to rebase it against these changes
before it can be submitted. 

The patch set I am proposing is not a panacea and will not solve all outstanding problems,
but apart from the ones that it solves I believe it can be of help in resolving the outstanding
problems; the sooner work and testing can start, the better. 

I can further identify with the problems reported on this list due to changes somewhere
else in the kernel tree. I normally test using a different hardware (SMP, 32 bit, 64 bit,
laptop, and some older PCs), but loyally tracking the recent changes in the bleeding edge
tree often means that some equipment can not be used for a while.
I think that this may be alleviated by not updating the base too frequently between kernel releaes
in the upcoming `DCCP experimental' tree.

Gerrit
