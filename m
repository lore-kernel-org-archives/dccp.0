From: David Miller <davem@davemloft.net>
Date: Thu, 11 Nov 2010 18:45:24 +0000
Subject: Re: net-next-2.6 [PATCH 0/3] dccp: Ack Vectors in circular buffer
Message-Id: <20101111.104524.48510509.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1289455653-5463-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1289455653-5463-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Nov 2010 07:07:30 +0100

>  Patch #1: cleans up the old interface to prepare for the improved one.
>  Patch #2: also tidies up the old interface, by separating the internals
>            of Ack Vectors from the option-parsing code.
>  Patch #3: Completes the implementation of a circular Ack Vector buffer.
> 
> 
> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']
> 
> The set has been tested for 3 years, and is fully bisectable.

Pulled, thanks!
