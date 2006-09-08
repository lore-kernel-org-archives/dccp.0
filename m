From: gerrit@erg.abdn.ac.uk
Date: Fri, 08 Sep 2006 10:49:14 +0000
Subject: Re: Proposed socket API change
Message-Id: <200609081149.14383@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609081031.41701@strip-the-willow>
In-Reply-To: <200609081031.41701@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > In a forthcoming communication to SIGCOMM-06, the inventors of DCCP say that
|  > they were "motivated by keeping the basic API as simple as UDP's" and that
|  > "DCCP should provide applications with an API as simple as that of UDP".
|  
|  I think the same authors killed me on this point.  I believe their motivation is
|  "we want service codes to be used" and that they are a useful thing.  I agree
|  with them, but I don't agree on "forcing the users to use service codes".  
I have the same idea; the proposal is an attempt to make the API simple without
contradicting the spec. UDP also does not contradict its spec and yet is simple
to program; if the same can be done with DCCP, that would be great. 

Thanks for mentioning dccp@ietf.org, have copied message there. If there are no 
strong objections, will send patch on Monday.

- Gerrit
