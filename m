From: David Miller <davem@davemloft.net>
Date: Sat, 13 Feb 2010 00:51:35 +0000
Subject: Re: net-2.6 [PATCH 0/2] udp/dccp: MSG_TRUNC
Message-Id: <20100212.165135.76878917.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Feb 2010 07:26:17 +0100

> I have here two datagram-API patches, both submitted for net-2.6:

These are not appropriate for net-2.6, so I will apply them to
net-next-2.6

> Patch #1: Resolves missing MSG_TRUNC support. Since DCCP is datagram-based,
>           the user-space API is broken/incomplete without.
> 
> Patch #2: UDP recvmsg() cleanup, remove redundant variable. 	  


Applied, thanks.
