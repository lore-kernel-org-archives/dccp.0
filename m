From: David Miller <davem@davemloft.net>
Date: Mon, 05 Jan 2009 05:46:00 +0000
Subject: Re: [PATCH 2/3] dccp: Clean up ccid.c after integration of CCID
Message-Id: <20090104.214600.119496484.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1230967849-9456-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1230967849-9456-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  3 Jan 2009 08:30:48 +0100

> This patch cleans up after integrating the CCID modules and, in addition,
> 
>  * moves the if/else cases from ccid_delete() into ccid_hc_{tx,rx}_delete();
>  * removes the 'gfp' argument to ccid_new() - since it is always gfp_any().
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied.
