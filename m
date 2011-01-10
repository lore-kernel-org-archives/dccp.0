From: David Miller <davem@davemloft.net>
Date: Mon, 10 Jan 2011 00:17:33 +0000
Subject: Re: net-next-2.6 [PATCH 0/3] dccp: several sequence-number
Message-Id: <20110109.161733.241928340.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri,  7 Jan 2011 12:35:27 +0100

> Hi Dave,
> 
> please find attached 3 bug fixes which recently came up on dccp@vger.
> 
>  Patch #1: fixes a bug which wrongly classified sequence-invalid packets. 
>  Patch #2: fixes a bug in updating the Greatest Sequence number Received (GSR).
>  Patch #3: fixes an inconsistency in setting the sequence window on 32/64 bit.
> 
> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

Pulled, thanks a lot Gerrit.
