From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 24 Sep 2008 14:01:21 +0000
Subject: Re: v2 [PATCH 2/5] dccp: Implement lookup table for
Message-Id: <20080924140121.GK9588@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080924051823.GB4944@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080924051823.GB4944@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Sep 24, 2008 at 07:18:23AM +0200, Gerrit Renker escreveu:
> This is the first revised patch, the second follows subsequently.
> 
> Changes relative to v1: 
> migrated function `dccp_default_value' moved to where it is first used 
> 
> >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp: Implement lookup table for feature-negotiation information
> 
> A lookup table for feature-negotiation information, extracted from RFC 4340/42,
> is provided by this patch. All currently known features can be found in this 
> table, along with their feature location, their default value, and type.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Lets make progress, in the future lets try and remove hardcoded specific CCID
tests.

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
