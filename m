From: David Miller <davem@davemloft.net>
Date: Wed, 01 Nov 2017 03:06:14 +0000
Subject: Re: [PATCH] net: dccp: ccids: lib: packet_history: use swap macro in tfrc_rx_hist_swap
Message-Id: <20171101.120614.957750555621662864.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Sat, 28 Oct 2017 15:48:47 -0500

> Make use of the swap macro and remove unnecessary variable tmp.
> This makes the code easier to read and maintain.
> 
> This code was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
