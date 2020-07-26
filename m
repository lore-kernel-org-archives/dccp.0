From: David Miller <davem@davemloft.net>
Date: Sun, 26 Jul 2020 07:46:44 +0000
Subject: Re: get rid of the address_space override in setsockopt v2
Message-Id: <20200726.004644.71243023033363639.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sun, 26 Jul 2020 09:03:11 +0200

> On Fri, Jul 24, 2020 at 03:43:42PM -0700, David Miller wrote:
>> > Changes since v1:
>> >  - check that users don't pass in kernel addresses
>> >  - more bpfilter cleanups
>> >  - cosmetic mptcp tweak
>> 
>> Series applied to net-next, I'm build testing and will push this out when
>> that is done.
> 
> The buildbot found one warning with the isdn debug code after a few
> days, here is what I think is the best fix:

I already fixed this in net-next.
