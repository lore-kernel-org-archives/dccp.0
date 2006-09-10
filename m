From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Sun, 10 Sep 2006 06:07:02 +0000
Subject: Re: Proposed socket API change
Message-Id: <4503AB86.3090208@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200609081031.41701@strip-the-willow>
In-Reply-To: <200609081031.41701@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Last time, vger ate this reply as possible spam, trying again.


Well, here's what I think about service codes.  I think I speak for the 
authors here.  This has all been said previously on the list FWIW.


* I think service codes should be part of the sockaddr for DCCP.  The decision 
to make them a setsockopt() I think has made things harder.  From 9/9/05:

 > I agree with Arnaldo et al. here.  The Service Code should be considered 
similar to a port.  It is best to specify it at bind() time, rather than 
separately.  The structure names may want some updating; sockaddr_in_dccp and 
sockaddr_in6_dccp, rather than sockaddr_dccp, for example.  The servicecode 
member should finish off the structure, so that sockaddr_in is a prefix of 
sockaddr_in_dccp.  And the code should be smart enough to supply a 0 service 
code if the sa_len corresponds to sockaddr_in instead of sockaddr_in_dccp.


* I am fine with the default service code being 0.  11/23/05:

 > Again, there's always Service Code 0, which "represents the absence of a 
meaningful Service Code".  This should be the default, if you desperately want 
a default.


* I am NOT fine, and have never been fine, with 0 acting as a *wildcard* in 
any way.  Service code 0 acts like a specific service code in every way: if a 
Request with Service Code 1 arrived at a listening socket with Service Code 0, 
then the Request would be rejected with Bad Service Code.  Likewise, if a 
Request with SC 0 arrived at a listening socket with SC 1, the Request would 
be rejected with Bad Service Code.


So to summarize, a default SC of 0 is fine, for either listening or active 
sockets, although we still think people should use real service codes.  If the 
following comment suggests woildcarding, then that's not fine.

 > So as to not compromise listening sockets, I was thinking of treating an 
`uninitialized' 0 on a server socket different from a service code = 0 which 
has been explicitly set by the application.



Eddie
