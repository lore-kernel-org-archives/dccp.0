From: David Miller <davem@davemloft.net>
Date: Mon, 05 Jan 2009 05:45:55 +0000
Subject: Re: [PATCH 1/3] dccp: Lockless integration of CCID
Message-Id: <20090104.214555.48754453.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1230967849-9456-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1230967849-9456-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  3 Jan 2009 08:30:47 +0100

> Based on Arnaldo's earlier patch, this patch integrates the standardised
> CCID congestion control plugins (CCID-2 and CCID-3) of DCCP with dccp.ko:
> 
>  * enables a faster connection path by eliminating the need to always go 
>    through the CCID registration lock;
> 
>  * updates the implementation to use only a single array whose size equals
>    the number of configured CCIDs instead of the maximum (256);
> 
>  * since the CCIDs are now fixed array elements, synchronization is no
>    longer needed, simplifying use and implementation.
> 
> CCID-2 is suggested as minimum for a basic DCCP implementation (RFC 4340, 10);
> CCID-3 is a standards-track CCID supported by RFC 4342 and RFC 5348.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied.
