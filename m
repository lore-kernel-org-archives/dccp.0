From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 21 Jul 2020 09:55:20 +0000
Subject: RE: [PATCH 03/24] net: add a new sockptr_t type
Message-Id: <9b7ae3245bad474db2a3889bc1c1a329@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-4-hch@lst.de>
In-Reply-To: <20200720124737.118617-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Biggers
> Sent: 20 July 2020 17:38
...
> How does this not introduce a massive security hole when
> CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE?
> 
> AFAICS, userspace can pass in a pointer >= TASK_SIZE,
> and this code makes it be treated as a kernel pointer.

One thought I've had is that on 64-bit architectures there
is almost always some part of the KVA that can never be valid
and is larger than the maximum size of a user VA.

If the user address is offset into this invalid area
then it can always be distinguished from a kernel address.

Indeed it may be worth considering offsetting kernel
addresses as well.

This forces code to use the correct accessors.

It doesn't solve the problem for 32bit systems with
CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE since
they are likely to have all 32bit addresses available
to both use and kernel.

If you end up with a 'fat pointer' then it may be worth
adding the length and making it a 'buffer descriptor'.
This can then be passed by address and the reduced
number of parameters will probably offset the cost
of the extra indirection.

The read/write functions could then take the 'buffer descriptor',
offset and length as parameters.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
