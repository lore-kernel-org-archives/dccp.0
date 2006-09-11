From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Sep 2006 13:30:47 +0000
Subject: Re: Proposed socket API change
Message-Id: <200609111430.47907@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609081031.41701@strip-the-willow>
In-Reply-To: <200609081031.41701@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Eddie,

many thanks for the references and comments; please see inline.

- Gerrit
  
|  * I think service codes should be part of the sockaddr for DCCP.  The decision 
|  to make them a setsockopt() I think has made things harder.  From 9/9/05:
|  
|   > I agree with Arnaldo et al. here.  The Service Code should be considered 
|  similar to a port.  It is best to specify it at bind() time, rather than 
|  separately.  The structure names may want some updating; sockaddr_in_dccp and 
|  sockaddr_in6_dccp, rather than sockaddr_dccp, for example.  The servicecode 
|  member should finish off the structure, so that sockaddr_in is a prefix of 
|  sockaddr_in_dccp.  And the code should be smart enough to supply a 0 service 
|  code if the sa_len corresponds to sockaddr_in instead of sockaddr_in_dccp.
I think the idea is good, but find the realisation problematic:

* sockaddr_in{,6}_dccp would be a special API exception, TCP/UDP use sockaddr_in/6, 
  all other sockaddr_xxx types are indexed by layer-3 name.

* since servers may multiplex different services over the same port, this would
  mean that sockaddr_dccp contains a variable-length list - which may be at odds
  with the maximum length of sockaddr_storage.

* would make integration with v4/v6 getaddrinfo() difficult. The glibc function 
  getaddrinfo() does not yet support DCCP (nor UDP-Lite),  but the conversion/
  upgrade is in principle simple(r) if sockaddr_in/6 are used, as the basic socket
  API can be retained.

Why not achieve the same by providing a library call which takes port number,
service number, v4/v6 address as argument and returns a connected/listening socket
handle? Maybe there is even potential for providing a library call for well-known
services such as get_service_and_port_by_name(), but all this leads far away from
what I actually was concerned about.
 
|  * I am fine with the default service code being 0.  11/23/05:
|  
|   > Again, there's always Service Code 0, which "represents the absence of a 
|  meaningful Service Code".  This should be the default, if you desperately want 
|  a default.
Yes, this is exactly what I meant to ask - if an application really has no present use
for a service code, then give it the default. All other applications will have to
consider the spec, RFC 4340, from which it is clear what to provide.

|  * I am NOT fine, and have never been fine, with 0 acting as a *wildcard* in 
|  any way.  Service code 0 acts like a specific service code in every way: if a 
|  Request with Service Code 1 arrived at a listening socket with Service Code 0, 
|  then the Request would be rejected with Bad Service Code.  Likewise, if a 
|  Request with SC 0 arrived at a listening socket with SC 1, the Request would 
|  be rejected with Bad Service Code.
The main concern was to simplify the socket programming API, while remaining fully
conformant with RFC 4340; without implying any bad uses of default values. 

  
|  So to summarize, a default SC of 0 is fine, for either listening or active 
|  sockets, although we still think people should use real service codes.  If the 
|  following comment suggests woildcarding, then that's not fine.
|  
|   > So as to not compromise listening sockets, I was thinking of treating an 
|  `uninitialized' 0 on a server socket different from a service code = 0 which 
|  has been explicitly set by the application.
That was my fault, the comment was a bit ill-formulated and clarified by one look
at the sources - it considered safely overriding the uninitialised service code state,
not wildcarding.
