From: David Miller <davem@davemloft.net>
Date: Wed, 13 Aug 2008 20:49:04 +0000
Subject: Re: [PATCH] dccp: change L/R must have at least one byte in the
Message-Id: <20080813.134904.123902363.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080813125532.GD12888@ghostprotocols.net>
In-Reply-To: <20080813125532.GD12888@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: gerrit@erg.abdn.ac.uk
Date: Wed, 13 Aug 2008 16:04:03 +0100 (BST)

> > dccp: change L/R must have at least one byte in the dccpsf_val field
> >
> > Thanks to Eugene Teo for reporting this problem.
> >
> > Signed-off-by: Eugene Teo <eugenete@kernel.sg>
> > Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> 
> Dave, can you please apply -- this patch is for mainline only.

Applied and I'll queue this up for -stable too, thanks everyone.
