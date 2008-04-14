From: David Miller <davem@davemloft.net>
Date: Mon, 14 Apr 2008 05:38:58 +0000
Subject: Re: [RFC][PATCH 10/12][NETNS][DCCPV6]: Move the dccp_v6_ctl_sk on
Message-Id: <20080413.223858.65283072.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <47FBAB09.9000305@openvz.org>
In-Reply-To: <47FBAB09.9000305@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 8 Apr 2008 15:18:04 -0300

> Em Tue, Apr 08, 2008 at 09:27:37PM +0400, Pavel Emelyanov escreveu:
> > diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> > index 2ca5291..109dab3 100644
> > --- a/net/dccp/ipv6.c
> > +++ b/net/dccp/ipv6.c
> > @@ -33,8 +33,7 @@
> >  #include "ipv6.h"
> >  #include "feat.h"
> >  
> > -/* Socket used for sending RSTs and ACKs */
> > -static struct sock *dccp_v6_ctl_sk;
> > +/* dccp_v6_ctl_sk is used for sending RSTs and ACKs */
> 
> Wrong comment?

Pavel, please send a patch to fix this up, relative to net-2.6.26

Thanks!
