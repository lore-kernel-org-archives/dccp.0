From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 25 Oct 2007 14:03:55 +0000
Subject: Re: systemtap networking tapsets was: Re: [RFC]: field name identifier conventions
Message-Id: <200710251503.55697@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20071022163144.GA15773@ghostprotocols.net>
In-Reply-To: <20071022163144.GA15773@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  The full sources for the tapsets used (for things like ccid3_hc_tx_sk_rtt(), etc) are at:
|  
|  http://oops.ghostprotocols.net:81/acme/nettaps.tar.bz2
|  
This is awesome. Is all that is needed to run these a new systemtap binary? Mine is 0.5.9
and too old for that, and I need to do some rtfm in the stap manuals.

It would be great to upload a few standard scripts and continually use them for regression
tests - it seems the stuff can again be wrapped into bash, python, etc, so that some test
runs could be automated.

|  Still a bit hackish, as we don't expose the ccids header files in
|  include/net/ for systemtap to use and I tried this on a kernel packaged
|  as an RPM (kernel-debuginfo, etc), perhaps something to consider
|  changing. 
When doing this for CCID2, the same problem arises. Maybe the struct_tfrc can be converted
into a generic (lean) info structure (suitable for multiple CCIDs), afaik DCCP is the only 
user of include/linux/dccp.h, while the real TFRC work is done in net/dccp/ccids/lib.
