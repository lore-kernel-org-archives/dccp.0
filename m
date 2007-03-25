From: David Miller <davem@davemloft.net>
Date: Sun, 25 Mar 2007 04:01:43 +0000
Subject: Re: [2.6 patch] make dccp_write_xmit_timer() static again
Message-Id: <20070324.210143.97294360.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070324130652.GJ752@stusta.de>
In-Reply-To: <20070324130652.GJ752@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 24 Mar 2007 14:06:52 +0100

> dccp_write_xmit_timer() needlessly became global.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
