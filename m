From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 25 Oct 2007 17:13:34 +0000
Subject: Re: systemtap networking tapsets was: Re: [RFC]: field name
Message-Id: <20071025171334.GF21383@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20071022163144.GA15773@ghostprotocols.net>
In-Reply-To: <20071022163144.GA15773@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Oct 25, 2007 at 03:03:55PM +0100, Gerrit Renker escreveu:
> |  The full sources for the tapsets used (for things like ccid3_hc_tx_sk_rtt(), etc) are at:
> |  
> |  http://oops.ghostprotocols.net:81/acme/nettaps.tar.bz2
> |  
> This is awesome. Is all that is needed to run these a new systemtap binary? Mine is 0.5.9
> and too old for that, and I need to do some rtfm in the stap manuals.

Here I have: 0.5.13, so you are not that off:

stap_fa52dacd83be5dbb4b8bcbb890f82bba_4257: systemtap: 0.5.13, base: ffffffff88365000, memory: 68795+40885+53408+164320+31157464 data+text+ctx+io+glob, probes: 4

 
> It would be great to upload a few standard scripts and continually use them for regression
> tests - it seems the stuff can again be wrapped into bash, python, etc, so that some test
> runs could be automated.

Indeed, having some scripts and using them for regression testing seems
like an excellent idea. We can use it to mangle a packet on its way to
some of our routines to check if they are handling some specific
failures, etc. Ultimately we could end up with a nice set of scripts
that would test each and every condition we have to handle. Coverage
analysis could then be done using lcov, that would be really nirvana 8)
 
> |  Still a bit hackish, as we don't expose the ccids header files in
> |  include/net/ for systemtap to use and I tried this on a kernel packaged
> |  as an RPM (kernel-debuginfo, etc), perhaps something to consider
> |  changing. 

> When doing this for CCID2, the same problem arises. Maybe the struct_tfrc can be converted
> into a generic (lean) info structure (suitable for multiple CCIDs), afaik DCCP is the only 
> user of include/linux/dccp.h, while the real TFRC work is done in net/dccp/ccids/lib.

Yeah, making it easier for systemtappin' is in my plans on the dccp
files layout. I'll even advocate for these scripts to be shipped with
the kernel sources.

Ok, back to TCP misuse investigations for a living, hope to have time to
merge some more patches later today. :-)

- Arnaldo
