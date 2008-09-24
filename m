From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 24 Sep 2008 13:59:54 +0000
Subject: Re: v2 [PATCH 1/5] dccp: Basic data structure for feature
Message-Id: <20080924135954.GJ9588@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080924052305.GC4944@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080924052305.GC4944@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Sep 24, 2008 at 07:23:05AM +0200, Gerrit Renker escreveu:
> This is the second/other revised patch for this set [v2 of 1/5].
> 
> Changes relative to v1: copied Arnaldos suggested layout and updated the
> struct documentation accordingly. Compile-tested the result.
> 
> >>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp: Basic data structure for feature negotiation
> 
> This patch prepares for the new and extended feature-negotiation routines.
> 
> The following feature-negotiation data structures are provided:
> 	* a container for the various (SP or NN) values,
> 	* symbolic state names to track feature states,
> 	* an entry struct which holds all current information together,
> 	* elementary functions to fill in and process these structures.
> 
> Entry structs are arranged as FIFO for the following reason: RFC 4340 specifies
> that if multiple options of the same type are present, they are processed in the
> order of their appearance in the packet; which means that this order needs to be
> preserved in the local data structure (the later insertion code also respects
> this order).
> 
> The struct list_head has been chosen for the following reasons: the most 
> frequent operations are
>  * add new entry at tail (when receiving Change or setting socket options);
>  * delete entry (when Confirm has been received);
>  * deep copy of entire list (cloning from listening socket onto request socket).
> 
> The NN value has been set to 64 bit, which is a currently sufficient upper limit
> (Sequence Window feature has 48 bit).
> 
> Thanks to Arnaldo who streamlined the field layout of the entry struct.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
