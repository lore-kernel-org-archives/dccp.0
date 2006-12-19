From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 19 Dec 2006 10:33:30 +0000
Subject: Re: 48-bit sequence number arithmetic
Message-Id: <200612191033.30858@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <45818142.4090001@cs.ucla.edu>
In-Reply-To: <45818142.4090001@cs.ucla.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Your solution differs than the usual 32-bit subtraction solution used 
|  for TCP, but it has interesting properties of its own.  We now have 
|  pairs of numbers where "a != b && !before48(a, b) && !before48(b, a)"!
For each number a there is one such number b = a + 2^(n-1)  = a - 2^(n-1)
(modulo 2^n). This means the above test can be used to identify this number,
as in all other cases either before48(a, b), or before48(b, a), or a = b.

With the previous solution one would have to eliminate the ambiguity by testing

 * whether before48(b, a) when before48(a, b)
 * whether before48(a, b) when before48(b, a)

This kind of test is more expensive. Likely, the advantages of the solution are more
theoretical in nature. But it may be interesting in light of testing against earlier
segments (quiet time, 2 MSL), or for DoS attacks, or choosing initial numbers.
