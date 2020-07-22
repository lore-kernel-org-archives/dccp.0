From: 'Christoph Hellwig' <hch@lst.de>
Date: Wed, 22 Jul 2020 08:01:42 +0000
Subject: Re: [PATCH 12/24] bpfilter: switch bpfilter_ip_set_sockopt to sockptr_t
Message-Id: <20200722080142.GA26841@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-13-hch@lst.de>
In-Reply-To: <20200720124737.118617-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Jul 22, 2020 at 10:00:23AM +0200, 'Christoph Hellwig' wrote:
> On Tue, Jul 21, 2020 at 08:36:57AM +0000, David Laight wrote:
> > From: Christoph Hellwig
> > > Sent: 20 July 2020 13:47
> > > 
> > > This is mostly to prepare for cleaning up the callers, as bpfilter by
> > > design can't handle kernel pointers.
> >                       ^^^ user ??
> 
> No, it can't handle user pointers. 

Err, I mean it can only handle user pointers.
