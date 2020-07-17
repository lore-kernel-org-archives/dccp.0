From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 17 Jul 2020 08:01:28 +0000
Subject: Re: [PATCH 22/22] net: make ->{get,set}sockopt in proto_ops optional
Message-Id: <5f88e695-d787-2191-feef-883a067788ed@pengutronix.de>
List-Id: <dccp.vger.kernel.org>
References: <20200717062331.691152-23-hch@lst.de>
In-Reply-To: <20200717062331.691152-23-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/17/20 8:23 AM, Christoph Hellwig wrote:
> Just check for a NULL method instead of wiring up
> sock_no_{get,set}sockopt.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  net/can/bcm.c               |  2 --
>  net/core/sock.c             | 14 --------------

For the CAN part:

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Marc

-- 
Pengutronix e.K.                 | Marc Kleine-Budde           |
Embedded Linux                   | https://www.pengutronix.de  |
Vertretung West/Dortmund         | Phone: +49-231-2826-924     |
Amtsgericht Hildesheim, HRA 2686 | Fax:   +49-5121-206917-5555 |
