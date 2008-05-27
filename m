From: David Miller <davem@davemloft.net>
Date: Tue, 27 May 2008 13:37:45 +0000
Subject: Re: [PATCH 7/7] [TCP][DCCP]: Consolidate duplicate code which does
Message-Id: <20080527.063745.105720366.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1211877167-10995-8-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1211877167-10995-8-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:47 +0100

> This patch consolidates the code common to TCP and CCID-2:
> 
>  * TCP uses RFC 3390 in a packet-oriented manner (tcp_input.c) and
>  * CCID-2 uses RFC 3390 in packet-oriented manner (RFC 4341).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Depends upon hctx prefix changes which will not be applied, please
repsin.
