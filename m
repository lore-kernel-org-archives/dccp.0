From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 21:34:52 +0000
Subject: Re: [PATCHES 0/8][DCCP] More core work
Message-Id: <20070926213452.GK10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20070926183900.GB10932@ghostprotocols.net>
In-Reply-To: <20070926183900.GB10932@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Sep 26, 2007 at 02:08:37PM -0700, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Date: Wed, 26 Sep 2007 15:39:00 -0300
> 
> > Hi David,
> > 
> > 	Please consider pulling from:
> > 
> > 	master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.24
> 
> Pulled, but I'd like to make a small request.
> 
> Please remove the CONFIG_IP_DCCP_CCID3_DEBUG ifdef protection
> for the BUG_ON(hctx = NULL)
> 
> Either the assertion is valid, and therefore it should always
> be enabled, or it isn't.
> 
> If people want to turn off BUG checks, they turn off CONFIG_BUG.

OK! I plead guilty for this one, Gerrit's patch didn't had that, will
fix it in the next batch.

- Arnaldo
