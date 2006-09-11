From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Sep 2006 14:17:02 +0000
Subject: Re: Proposed socket API change
Message-Id: <200609111517.02465@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609081031.41701@strip-the-willow>
In-Reply-To: <200609081031.41701@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian,
|  > Thanks for mentioning dccp@ietf.org, have copied message there. If there are no
|  > strong objections, will send patch on Monday.
|  >
|  > - Gerrit
|  
|  I agree about the service code personally but we shouldn't accept into
|  Linux something that deliberately breaks the RFC. We need to convince
|  the protocol authors first.
That is a good point.

I am in the process of compiling a `dccp socket programming mini how-to', in which all 
these questions play a role. I am currently using the Wand pages as input but would 
appreciate any other information, e.g. if the pmtu discovery issue reported on
http://linux-net.osdl.org/index.php/DCCP_Testing
has been resolved (the to-do list of the same server lists only `PMTU'; if it
is not resolved, it would be a next thing).

- Gerrit

