From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Nov 2007 14:07:43 +0000
Subject: Re: Test tree patch inventory - update: 3rd batch
Message-Id: <20071121140743.GB17659@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071121124214.GC24995@ghostprotocols.net>
In-Reply-To: <20071121124214.GC24995@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > 7. Miscellaneous DCCP updates
| > -----------------------------
<snip>
| > 	[DCCP]: Promote CCID2 as default CCID
| 
| Applied to simplify things for now, but I still think that for some
| setups it may be interesting to allow CCID2 not to be built. 
| 
Yes, there is room to revise this for something better later on. I think
this is much similar to the "use Reno or Cubic as default" in TCP, and 
maybe one could use a similar Kconfig menu as it is currently done for
the TCP modules.
  
| > 
| > 8. The Feature-Negotiation patch set
| > ------------------------------------
| > The set splits into several smaller (self-contained) blocks, all documented in this section.
| > The first block is distinct from feature negotiation, it only concerns request sockets:
| > 
| > 	[DCCP]: Allow to parse options on Request Sockets
| 
| This one can be folded with the next, I guess, since its only use of
| the newly introduce dreq on dccp_parse_options is to test against NULL,
| but that could be achieved by checking the packet type.
| 
| > 	[DCCP]: Add (missing) option parsing to request_sock processing
Yes this is a tiny one. The first patch introduces the general code, the
second is separate just because it adds the newly updated
dccp_parse_options() to dccp_check_req(). 

This is a question I am often puzzled about -- picking the right granularity of patches. 
Often it is quite fine-granular, so please do feel free to combine;
breaking them into single ones is mostly for reviewing/readability.
