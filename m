From: David Miller <davem@davemloft.net>
Date: Thu, 19 Aug 2010 06:25:32 +0000
Subject: Re: dccp test-tree [PATCH 0/3] ccid-2: Congestion Window
Message-Id: <20100818.232532.98880936.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Aug 2010 07:21:38 +0200

> This is a small set to enhance CCID-2, consisting mainly of Congestion Window
> Validation (RFC 2681) ported over from TCP.
> 
> The first patch allows to make the TCP minimum RTO visible also to CCID-2. Since
> CCID-3 also uses RTO (in the formula and for the nofeedback timer), I wonder
> whether we should also do the same for CCID-3??
> 
> The changeset is:
> 
>   Patch #1: makes TCP's minimum-RTO code available to CCID-2
>   Patch #2: simplifies the code by using an existing function
>   Patch #3: implements CWV for CCID-2 -- largely taken from TCP
> 
> The patches have been dusted off from my development tree. They have been tested,
> though it is some time ago. Hence I'd very much appreciate review and comments.

I think these changes are wonderful.

I'll add them to net-next-2.6, thanks a lot!
