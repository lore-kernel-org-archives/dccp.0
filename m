From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 20 Oct 2007 15:54:35 +0000
Subject: [RFC]: field name identifier conventions
Message-Id: <200710201654.35326@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have a question/suggestion for DCCP/CCID field names, which have a tendency to grow
into really_quite_long_strings. The convention for field members seems to be


	"x"->"x"_<fieldname>

Examples are in particular

   * hctx->ccid2hctx_<fieldname>
   * hcrx->ccid3hcrx_<fieldname>
   * avr->dccpavr_<fieldname>
   * av->dccpav_<fieldname>

The problem is that this naming convention has no apparent benefits: 
  
  * which struct is used is evident from the context and need not be encoded
  * someone reading the code is only interested in the fieldnames
  * with the line length limit of 80 characters this convention almost inevitably leads to
    multi-line expression for even the simplest kinds of comparisons and expressions.

Hence my suggestion is to reduce the replicated "x" field prefix, so that field members become
shorter, as will be expressions, and the code would be easier to read.

What is the opinion of other developers / maintainer regarding this? 


