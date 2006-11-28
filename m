From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 21:56:05 +0000
Subject: Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <200611282156.11750@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611281435.05466@strip-the-willow>
In-Reply-To: <200611281435.05466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Eddie Kohler:
|  > |  > Would really appreciate if you could at some time have a look at the moving-average patch. Have communicated
|  > |  > with Eddie again about it, and using MSS would at the moment be much more complicated.
|  > |  >
|  > |  Will look at it tomorrow (along with performance testing existing
|  > |  changes in tree) as meant to be preparing coursework and working on
|  > |  PhD today.... Agree MSS is problematic at present without PMTU.
|  
|  I guess I don't understand why using MSS is problematic for congestion 
|  control; since assuming that s=MSS causes s to drop out of all congestion 
|  control equations, returning them to packet-based CC.  One could therefore set 
|  "s=ANY_ARBITRARY_VALUE" and get the same result.  Ah, well!  Yes, providing 
|  lots of options is harder for users than providing the one right answer, but 
|  we just don't know what that right answer is.  It will be interesting to see 
|  how the moving-average patch actually behaves in practice; the Internet has 
|  much more experience with s=MSS/packet-based CC.
That would be an interesting feature to have once PMTUD is fixed (and PMTUD should also communicate
expected header lengths via the CCID interface); I agree that cancelling out `s' out of the equation
would, in the long run, probably make things simpler. But for the moment I'd prefer to plug all the
existing holes and then return to such things.
