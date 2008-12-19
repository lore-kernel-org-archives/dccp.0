From: David Miller <davem@davemloft.net>
Date: Fri, 19 Dec 2008 06:28:42 +0000
Subject: Re: [RFCv2][PATCH] static builtin CCIDs was Re: [PATCH 2/5] dccp:
Message-Id: <20081218.222842.174783235.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20081217214608.GC14518@ghostprotocols.net>
In-Reply-To: <20081217214608.GC14518@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 19 Dec 2008 06:24:46 +0100

> | > | Gerrit, are you OK with this?
> | > | 
> | > Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> | 
> | Applied, thanks everyone.
> | 
> I am sorry but I have to revert the Acked-by. As per
> yesterday's email I was ok with the basic idea, but
> already said that this did not include testing.
> 
> Please do not apply this patch yet, it introduces several
> new problems and needs more work.

You are so incredibly lucky I didn't push this out to kernel.org yet,
it's been sitting in my tree all day long.

Don't say ACK unless you mean it.

It's reverted but you should do real reviews before you ACK changes in
the future.

