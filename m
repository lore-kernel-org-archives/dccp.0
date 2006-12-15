From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 08:59:57 +0000
Subject: Re: 48-bit sequence number arithmetic
Message-Id: <200612150859.58016@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <45818142.4090001@cs.ucla.edu>
In-Reply-To: <45818142.4090001@cs.ucla.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Eddie,

sorry there is a bit of confusion here. For the record, please let's move the
issue whether RFC 4340 is right or not out of the focus. If you say it is right,
I will not argue with it; but there are useful and valid points that can be
used to make existing algorithms better. 

And I think it is time well spent to think these issues through, in particular since
the performance of CCID 3 for instance depends on the accuracy with which loss is 
detected - therefore I don't think that it harms to strive for maximum precision in
these matters.


|  - Patches to clean up sequence number arithmetic are fine.
|  - Your analysis of the 2^47 problem is not correct, however.  As RFC 1982 
|  says, two 48-bit numbers which are 2^47 apart are *unordered*.  Think about 
|  it: You see 0 and 2^47.  The distance between 0 and 2^47 is, IN EITHER 
|  DIRECTION, exactly 2^47.  Neither can be declared before the other.
Although RFC 1982 is about serial numbers as they are used in the Domain Name
System, it is a very useful reference here. Your point is valid, and it is solved
by the solution below. My point here is that for 2^(n-1) the result should really be
'undefined': with the current solution of subtraction, the result is not undefined,
but ambiguous.

|  - This is exactly the same case as in 32-bit TCP sequence number comparisons. 
You are right and therefore RFC 4340 is not `wrong'. It is strange that this way
of comparing sequence numbers has survived for so long: as early as 4.4BSDLite
(the SEQ_LEQ macros in Stevens vol II), until today's Linux IP stack.


|  - Therefore I'd recommend staying with the simplest check you can find, which 
|  may be the 64-bit trick recommended by RFC4340.
I found a solution which is as easy to implement as that _and_ removes the ambiguity.
It is, for two n-bit sequence numbers a and b, as follows:
	
 	a `before' b <=>         1 <= b-a <= 2^(n-1) - 1

To contrast: the previous definition was:

	a `before' b <=>   2^(n-1) <= a-b <= 2^n-1

and it suffers from the ambiguity problem when a-b = 2^(n-1). With the former solution,
the ambiguity is removed: whenever the difference between a and b is 2^(n-1), the result
is 2^(n-1) and thus neither a `before' b nor b `before' a: this is exactly what RFC 1982
suggests.

And my suggestion is not even new: we say "it is 29 minutes /before/ xxx o'clock", but we
don't say "it is /half/ before xxx o'clock". 

To summarise, the revised algorithm is:
	* store 48-bit numbers in leftmost fields of 64-bit numbers as per RFC 4340
	* a sequence number comparison based on the following pseudo-code:
  		int before48(u64 a, u64 b) { return ((b << 16) - (a << 16)) > 0; }
	* this removes the ambiguity
	* same suggestion was made for 32-bit TCP sequence numbers to netdev@vger


Gerrit
