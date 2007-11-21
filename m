From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 21 Nov 2007 12:42:14 +0000
Subject: Re: Test tree patch inventory - update: 3rd batch
Message-Id: <20071121124214.GC24995@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Nov 17, 2007 at 03:42:52PM +0000, Gerrit Renker escreveu:
> 
> 
> 7. Miscellaneous DCCP updates
> -----------------------------
> The last batch before the begin of the feature-negotiation patch set contains individual,
> standalone patches (and thus ideal for cherry-picking):
> 
> 	[DCCP]: Honour and make use of shutdown option set by user

Applied

> 	[DCCP]: Update documentation

Applied
 
> 	[DCCP]: Promote CCID2 as default CCID

Applied to simplify things for now, but I still think that for some
setups it may be interesting to allow CCID2 not to be built. 

> 	[DCCP]: Remove redundant dependency on IP_DCCP

Applied

> 	[DCCP]: Ignore Ack Vectors / Elapsed Time on DCCP-Request also

Applied
 
> 	[DCCP]: Update documentation on ioctls

Applied
 
> 
> 8. The Feature-Negotiation patch set
> ------------------------------------
> The set splits into several smaller (self-contained) blocks, all documented in this section.
> The first block is distinct from feature negotiation, it only concerns request sockets:
> 
> 	[DCCP]: Allow to parse options on Request Sockets

This one can be folded with the next, I guess, since its only use of
the newly introduce dreq on dccp_parse_options is to test against NULL,
but that could be achieved by checking the packet type.

> 	[DCCP]: Add (missing) option parsing to request_sock processing
> 	[DCCP]: Handle timestamps on Request/Response exchange separately
> 	[DCCP]: Support inserting options during the 3-way handshake
