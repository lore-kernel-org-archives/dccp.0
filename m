From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Jun 2007 09:06:45 +0000
Subject: Re: Regression Tests
Message-Id: <200706271006.45899@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706251036.54465@strip-the-willow>
In-Reply-To: <200706251036.54465@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorry this was all due to my not reading the page carefully enough. 

You have done an excellent job of setting all this information up (and selecting meaningful 
test cases in the first place), so that it should now be much easier to assess CCID3 performance. 

With the spreadsheet I get the same results also; for quick tests I find Perry's calculator
too powerful (too many knobs), using spreadsheet or calculator is better.

Thanks,
Gerrit

Quoting Ian McDonald:
|  Gerrit,
|  
|  It was my fault for using the TFRC throughput page and not changing
|  delayed acks from 2 to 1 which is used in RFC3448 (and our code) as
|  the default. I've gone and corrected my figures. I'm now within 1% of
|  your figures - I think this is rounding error from bc but not 100%
|  sure. I've attached the spreadsheet I used for verification which
|  matched Perry's page.
|  
|  The scripts are all on that page at
|  http://linux-net.osdl.org/index.php/DCCP_Testing#netem and loading
|  CCID3 at http://linux-net.osdl.org/index.php/DCCP#Choosing_and_initialising_your_CCID
|  
|  Maybe I have not worded it well? If not please feel free to improve.
|  
|  Regards,
|  
|  Ian
|  
|  On 6/25/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > Ian -
|  >
|  > |  Results here now:
|  > |  http://linux-net.osdl.org/index.php/DCCP_Testing#Regression_testing
|  >
|  > many thanks indeed for working out these test cases and reference points.
|  > Testing is really very much needed at this stage and the input is helpful.
|  >
|  > The test setup is very useful and I am strongly in favour of using
|  >
|  >      http://linux-net.osdl.org/index.php/DCCP_Testing#Regression_testing
|  >
|  > as a kind of benchmark for all further development on the test tree - to see
|  > whether results deteriorate.
|  >
|  > If you have links to scripts you use that would be great.
|  >
|  >
|  >
|  > I am getting confused by Perry's throughput calculator. Attached is a
|  > simple bc(1) script which can be made executable and takes s, R, p.
|  >
|  > I get different results from the ones on the web page (using 1424 bytes):
|  >
|  >   * for the 150ms / 10% case, I get Xcalc = 132.44  Kbits/sec and
|  >   * for the  40ms / 1%  case, I get Xcalc =   3.27  Mbits/sec
|  >
|  > But this may likely be due to using slightly different `s' and rounding errors;
|  > for live testing it is reasonably close.
|  >
|  >
|  
|  
