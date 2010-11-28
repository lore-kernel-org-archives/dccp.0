From: David Miller <davem@davemloft.net>
Date: Sun, 28 Nov 2010 19:29:48 +0000
Subject: Re: net-2.6 [Patch 1/1][BUG-FIX] dccp: advancing the Ack window
Message-Id: <20101128.112948.15234568.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20101123123656.GB3915@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20101123123656.GB3915@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Nov 2010 13:36:56 +0100

> dccp: fix error in updating the GAR
> 
> This fixes a bug in updating the Greatest Acknowledgment number Received (GAR): 
> the current implementation does not track the greatest received value -
> lower values in the range AWL..AWH (RFC 4340, 7.5.1) erase higher ones.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks.
