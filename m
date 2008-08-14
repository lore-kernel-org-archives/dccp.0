From: David Miller <davem@davemloft.net>
Date: Thu, 14 Aug 2008 01:12:26 +0000
Subject: Re: [PATCH] dccp: change L/R must have at least one byte in the
Message-Id: <20080813.181226.115891097.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080813125532.GD12888@ghostprotocols.net>
In-Reply-To: <20080813125532.GD12888@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Eugene Teo" <eugeneteo@kernel.sg>
Date: Thu, 14 Aug 2008 09:08:56 +0800

> On Wed, Aug 13, 2008 at 8:55 PM, Arnaldo Carvalho de Melo
> <acme@redhat.com> wrote:
> > Hi David, Gerrit,
> >
> >        Please consider applying.
> >
> > - Arnaldo
> >
> > dccp: change L/R must have at least one byte in the dccpsf_val field
> >
> > Thanks to Eugene Teo for reporting this problem.
> >
> > Signed-off-by: Eugene Teo <eugenete@kernel.sg>
> 
> Should be eugeneteo@ instead of eugenete. Thanks.

I'll fix this up for the -stable submission, this version
is already in my net-2.6 tree and on the way to Linus.

Thanks.

