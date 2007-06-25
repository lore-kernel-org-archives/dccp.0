From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jun 2007 09:36:54 +0000
Subject: Re: Regression Tests
Message-Id: <200706251036.54465@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_2y4fGN3knUpiKd/"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_2y4fGN3knUpiKd/
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Ian -

|  Results here now:
|  http://linux-net.osdl.org/index.php/DCCP_Testing#Regression_testing

many thanks indeed for working out these test cases and reference points.
Testing is really very much needed at this stage and the input is helpful.

The test setup is very useful and I am strongly in favour of using
 
     http://linux-net.osdl.org/index.php/DCCP_Testing#Regression_testing

as a kind of benchmark for all further development on the test tree - to see
whether results deteriorate.

If you have links to scripts you use that would be great. 



I am getting confused by Perry's throughput calculator. Attached is a
simple bc(1) script which can be made executable and takes s, R, p.

I get different results from the ones on the web page (using 1424 bytes):

  * for the 150ms / 10% case, I get Xcalc = 132.44  Kbits/sec and 
  * for the  40ms / 1%  case, I get Xcalc =   3.27  Mbits/sec

But this may likely be due to using slightly different `s' and rounding errors;
for live testing it is reasonably close.

--Boundary-00=_2y4fGN3knUpiKd/
Content-Type: text/plain;
  charset="iso-8859-1";
  name="throughput_calculator.bc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="throughput_calculator.bc"

#!/usr/bin/bc -l
#
# Compute the allowed sending rate X_calc using the formula of [RFC 3448, 3.1].
#
# This script can be run standalone, or using a pipe.
# For example, to compute  for 
#   *   s=1424  bytes, 
#   * RTT= 150  milliseconds, and 
#   *  p =  10  %,
# use
#	 echo 1424 150 10 | ./throughput_calculator.bc
#
# The result is about 132 Kbits/sec

scale = 3

define f(p) { return sqrt(2*p/3) + 12 * sqrt(3*p/8) * (32 * p^3 + p) }
define xcalc(s,r,p) { return s*8 * 10^3/(r * f(p/100.0)) }

print "TFRC throughput calculator\n\n"

print "s   in bytes: "; s = read()
print "RTT in msecs: "; r = read()
print "p   in %    : "; p = read()

print "\nXcalc = ", xcalc(s,r,p) / 1024.0, " Kbits/sec\n"
quit

--Boundary-00=_2y4fGN3knUpiKd/--
