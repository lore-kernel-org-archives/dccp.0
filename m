From: David Miller <davem@davemloft.net>
Date: Tue, 27 May 2008 13:37:14 +0000
Subject: Re: [PATCH 6/7] [CCID-2/3]: Fix sparse warnings
Message-Id: <20080527.063714.19615390.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1211877167-10995-7-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1211877167-10995-7-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:46 +0100

> This patch fixes the following two sparse warnings:
> 
>  1. Due to a nested min(max()) expression, sparse gave the following warnings:
> 
>     net/dccp/ccids/ccid3.c:91:21: warning: symbol '__x' shadows an earlier one
>     net/dccp/ccids/ccid3.c:91:21: warning: symbol '__y' shadows an earlier one
> 
>     (Didn't use clamp() here since this part is liketly to be split later, when
>      implementing the changes from draft rfc3448bis.)
> 
>  2. Declaration of function prototypes was in .c instead of .h file.
>     This resulted in "should it be static" warnings. Corrected by moving the
>     declarations to the tfrc.h file instead of the tfrc.c file.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Conflicts with hctx prefix changes, please respin.
