From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 21 Jul 2020 08:36:57 +0000
Subject: RE: [PATCH 12/24] bpfilter: switch bpfilter_ip_set_sockopt to sockptr_t
Message-Id: <f9493b4c514441b4b51bc7e4e75e8c40@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-13-hch@lst.de>
In-Reply-To: <20200720124737.118617-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Christoph Hellwig
> Sent: 20 July 2020 13:47
> 
> This is mostly to prepare for cleaning up the callers, as bpfilter by
> design can't handle kernel pointers.
                      ^^^ user ??

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
