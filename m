From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 18:49:44 +0000
Subject: [PATCH 0/3]:  TFRC documentation and updates
Message-Id: <200611271849.44310@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_INzaFGboAKLnqgZ"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_INzaFGboAKLnqgZ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

With the help of some test and verification programs, I have reverse-engineered
how the TFRC lookup table is generated. The results of this were added as detailed
documentation to the tfrc_equation.c file. 

The work also has made possible a few improvements which are included in this patch set.
A detailed analysis plus the test programs are online on 
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/tfrc_documentation/ 


Patch 1: This adds the documentation to tfrc_equation.c and
	  * fixes a small bug in the reverse-lookup code which incurred an average
            error of 1.12% (the bug was due to a missing '+ 1' in inverting the indices;
            this was confirmed using one of the online test programs)  
          * simplifies BUG conditions - if RTT = 0, the maximum = ~0U is now returned
          * adds warnings in both functions when p goes below the resolution of the
            table (the smallest possible value is 0.0001) 


Patch 2:  Avoid masking resolution errors in table lookup
          The lookup table can not resolve values of p smaller than 0.0001. I have checked
          the error that results by substituting other values and it is not a good idea.
          Attached is the calculation of the error when substituting f(0.0001) for values 
          of p smaller than 0.0001. Both axes are logarithmic - the increase in error is thus
          exponential. 
          Warning messages to avoid `resolution underflow' have already been introduced in the
          first patch; this patch continues this work by making all error handling local to the
          TFRC library. If the warning messages accumulate, it is an indication that the lookup
          table does not have suitable proportions and a larger one should be generated. 


Patch 3: Use binary search in reverse lookup
         This speeds up reverse lookups, exploiting the following feature:
          The lookup table is sorted (since i < j => f(i) < f(j)). Currently, if every interval
          is equally likely, the average number of iterations to reverse-lookup is 250. With bin
          search this goes down to 8 or 9 (log2(500)), which is almost 30 times faster. I have
          verified this also using tests.


Gerrit

--Boundary-00=_INzaFGboAKLnqgZ
Content-Type: image/png;
  name="tfrc_resolution-error_for_smallest_p.png"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="tfrc_resolution-error_for_smallest_p.png"

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
AElFTkSuQmCC

--Boundary-00=_INzaFGboAKLnqgZ--
