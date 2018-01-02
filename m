From: David Miller <davem@davemloft.net>
Date: Tue, 02 Jan 2018 18:50:25 +0000
Subject: Re: [PATCH 03/12] net: dccp: drop unneeded newline
Message-Id: <20180102.135025.617695999212757046.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed, 27 Dec 2017 15:51:36 +0100

> DCCP_CRIT prints some other text and then a newline after the message
> string, so the message string does not need to include a newline
> explicitly.  Done using Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
