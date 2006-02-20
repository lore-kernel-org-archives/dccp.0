From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 20 Feb 2006 20:44:56 +0000
Subject: Re: 2.6.16-rc4-mm1
Message-Id: <20060220204456.GG4661@stusta.de>
List-Id: <dccp.vger.kernel.org>
References: <43F9CE18.10709@trash.net>
In-Reply-To: <43F9CE18.10709@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Feb 20, 2006 at 03:11:36PM +0100, Patrick McHardy wrote:
> Reuben Farrelly wrote:
> > Minor dependency issue:
> > 
> > My compile failed with this..
> > 
> >   CC [M]  net/netfilter/xt_dccp.o
> > In file included from net/netfilter/xt_dccp.c:15:
> > include/linux/dccp.h:341:2: error: #error "At least one CCID must be
> > built as the default"
> > make[2]: *** [net/netfilter/xt_dccp.o] Error 1
> > make[1]: *** [net/netfilter] Error 2
> > make: *** [net] Error 2
> > [root@tornado linux-2.6-mm]#
> > 
> > [I have no idea what a CCID is]
> > 
> > But it was caused by this:
> > 
> > CONFIG_NETFILTER_XT_MATCH_DCCP=m
> > 
> > and maybe this below had an impact:
> > 
> > #
> > # DCCP Configuration (EXPERIMENTAL)
> > #
> > # CONFIG_IP_DCCP is not set
> > 
> > After unsetting the option to build the DCCP Netfilter module, I was
> > able to compile through to completion.
> 
> Ideally this dependency should be enforced by Kconfig. I'm not sure
> if it is possible to express something like "IP_DCCP_CCID2 and
> IP_DCCP_CCID3 depend on DCCP, DCCP requires at least one of both
> to be enabled". Can someone more familiar with Kconfig than me
> comment on this? Otherwise the #error should be moved to
> net/dccp/options.c to keep dccp.h usable without dccp enabled.

I can try to do it, but I need the exact semantics.

Should all of the following stay allowed configurations?

CONFIG_IP_DCCP=y
CONFIG_IP_DCCP_CCID2=m
CONFIG_IP_DCCP_CCID3=n

CONFIG_IP_DCCP=y
CONFIG_IP_DCCP_CCID2=y
CONFIG_IP_DCCP_CCID3=m

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

