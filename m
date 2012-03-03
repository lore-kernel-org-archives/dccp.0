From: David Miller <davem@davemloft.net>
Date: Sat, 03 Mar 2012 19:57:24 +0000
Subject: Re: [PATCH 0/2][BUG-FIX] dccp: two bug-fixes
Message-Id: <20120303.145724.979579867935018033.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1330792433-15415-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1330792433-15415-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  3 Mar 2012 09:33:51 -0700

> please find attached two bug fix patches for DCCP.  
> 
>  Patch #1: removes a BUG_ON which got triggered under normal operational conditions,
>            found that it is not even necessary, hence replaced;
>  Patch #2: fixes sequence number handling during initial connection setup, ensuring
>            connection establishment even if one or more initial Request(s) get lost.
> 
> The patches are also available applied on top of today's net-next, at
> 
> 	git://eden-feed.erg.abdn.ac.uk/net-next  [subtree 'dccp']
> 
> All patches have been tested and compile independently.

Pulled, thanks a lot Gerrit.
