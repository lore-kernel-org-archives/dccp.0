From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 18:25:43 +0000
Subject: [PATCH 0/8]: 2 Bug fixes, all earlier patches revised
Message-Id: <200612011825.43747@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have been doing bug hunting almost all day, two bug fixes are enclosed, 
for the remainder I am willing to stick my head into the code next week
until the performance is up to a reasonable level and most of the known
bugs are ironed out. 

I went through the earlier patches and tossed out some material and re-arranged
the TFRC lookup stuff in a different way. I think it is now much easier to read.


Patch 1: Bug fix: sending rates were calculated before X_recv/p  were updated
Patch 2: Removes the `Illegal ACK received message' [it is harmless]
 

Patches 3..8 correspond to the earlier TFRC patches (much smaller now): 
     Ian I would appreciate if you could have a look at these. 
     I have put in effort to explain them clearer. While the performance still
     is bad, these are a step forward. In particular, the parameter checking is
     useful to have.  Should it be needed, I have documented all everything on
     http://www.erg.abdn.ac.uk/users/gerrit/dccp/tfrc_documentation/doc/


Patch 3: just adds documentation for the TFRC lookup table; no code change, but
         this provides the basis for all other patches (the formulas)

Patch 4: corrects a small error in the reverse lookup function; I 
         have now added a detailed explanation _why_ this is an error.

Patch 5: adds extensive parameter checking to the TFRC lookup routines.

Patch 6: wraps up the previous steps by simplifying the forward lookup. 
         It also defines a constant for the lowest possible resolution and
         adds a warning if p is greater than 0 and less than this threshold.

Patch 7: deprecates the use of TFRC_SMALLEST_P in ccid3.c. It is subsumed
         by the minimum threshold set in Patch 4. The use of TFRC_SMALLEST_P
         is dangerous, as it masks large errors for low values of p.
         The resolution error is exactly given by:
           (f(0.0001) - f(p))/f(p) * 100
         and for TFRC_SMALLEST_P = 0.00004 this is still a value of about 58%!
         It is better to observe the warning messages and generate a new table
         in case there are too many warnings.

Patch 8: adds bin-search which should speed up TFRC reverse-lookup a little
