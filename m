From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 23 Jul 2020 11:16:16 +0000
Subject: RE: [PATCH 13/26] bpfilter: switch bpfilter_ip_set_sockopt to sockptr_t
Message-Id: <621e193e4af74d8198ed87d6a9ce8260@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-14-hch@lst.de>
In-Reply-To: <20200723060908.50081-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Christoph Hellwig
> Sent: 23 July 2020 07:09
> 
> This is mostly to prepare for cleaning up the callers, as bpfilter by
> design can't handle kernel pointers.

You've failed to fix the sense of the above...

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
