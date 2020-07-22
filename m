From: 'Christoph Hellwig' <hch@lst.de>
Date: Wed, 22 Jul 2020 08:00:23 +0000
Subject: Re: [PATCH 12/24] bpfilter: switch bpfilter_ip_set_sockopt to sockptr_t
Message-Id: <20200722080023.GC26554@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-13-hch@lst.de>
In-Reply-To: <20200720124737.118617-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 21, 2020 at 08:36:57AM +0000, David Laight wrote:
> From: Christoph Hellwig
> > Sent: 20 July 2020 13:47
> > 
> > This is mostly to prepare for cleaning up the callers, as bpfilter by
> > design can't handle kernel pointers.
>                       ^^^ user ??

No, it can't handle user pointers. 
