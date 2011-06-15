From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Jun 2011 05:10:15 +0000
Subject: Re: Testing Tree Timeline
Message-Id: <20110615051015.GA4682@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4DF637A8.5090104@ohio.edu>
In-Reply-To: <4DF637A8.5090104@ohio.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Samuel,

you can rest assured that your patches will eventually be submitted to the
netdev list and from there to David Miller.

I apologize that this has not progressed faster, but I can only confirm
what Ian just said. 

There are dependencies between the patches and your set is pretty much at
the top, I will need some time to refactor and sort out the dependencies.

I am sorry I can't give you a promise to have all this wrapped up by Monday
or so, this is work done out of hours, it may take a few weeks since I like
to submit patches in small chunks of about 5-6 in order to respect the 
workload that the higher-level maintainers have.

So please bear with me, it may just take a little while but we will get 
there eventually.

Gerrit


Quoting Samuel Jero:
| Hello All,
| 
| I was wondering what the current timeline looks like for integrating the
| patches in the testing tree into the mainline kernel?
| 
| Myself, and several other researchers at Ohio University, believe that
| DCCP would be an ideal protocol for encapsulating Delay Tolerant
| Networking protocols for transportation across the Internet. For testing
| purposes, we do not desire guaranteed reliability, but do require
| congestion control.
| 
| After testing (and bug fixing) DCCP for most of the last year, we are
| convinced that DCCP with CCID2 will be effective for our goals. In fact,
| we are in the process of writing an Internet Draft to recommend that
| other researchers use DCCP for encapsulating these DTN protocols.
| 
| However, the CCID2 code in the mainline kernel is very buggy and suffers
| from very poor performance. As a result, the only way to get a version
| of CCID2 that works well is to build a custom kernel from the testing
| tree. This, obviously, puts a damper on adoption.
| 
| As a result, it would be nice to have some idea of when code typically
| migrates from the testing tree into the mainline kernel and how that
| determination is made.
| 
| Thanks.
| 
| Samuel Jero
| Internetworking Research Group
| Ohio University
| 



-- 
