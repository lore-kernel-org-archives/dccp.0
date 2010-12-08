From: David Miller <davem@davemloft.net>
Date: Wed, 08 Dec 2010 18:01:29 +0000
Subject: Re: net-next-2.6 [PATCH 0/2] dccp: Policy-based packet dequeueing
Message-Id: <20101208.100129.35023767.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1291621444-5927-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1291621444-5927-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon,  6 Dec 2010 08:44:02 +0100

> Hi Dave,
> 
> please find attached a self-contained 2-patch set by Tomasz which adds an API
> to influence DCCP packet dequeueing. It evolved from discussions in 2008,
> adding and adds basic building blocks for sending congestion controlled
> multimedia packets that have a priority or a deadline attached to them.
> 
> Occasionally people still make new suggestions for such an API, apparently
> overlooking the excellent work Tomasz has done and which has been in the
> test tree for two years.
> 
>  Patch #1: introduces the new policy-based packet dequeueing infrastructure.
>  Patch #2: adds parameter (sanity) checking of cmsg qpolicy parameters.
> 
> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']
> 
> The set is fully bisectable.

Looks good, pulled, thanks a lot!
