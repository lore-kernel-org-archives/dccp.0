From: 'Christoph Hellwig' <hch@lst.de>
Date: Thu, 23 Jul 2020 11:44:58 +0000
Subject: Re: [PATCH 13/26] bpfilter: switch bpfilter_ip_set_sockopt to sockptr_t
Message-Id: <20200723114458.GA31363@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-14-hch@lst.de>
In-Reply-To: <20200723060908.50081-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Jul 23, 2020 at 11:16:16AM +0000, David Laight wrote:
> From: Christoph Hellwig
> > Sent: 23 July 2020 07:09
> > 
> > This is mostly to prepare for cleaning up the callers, as bpfilter by
> > design can't handle kernel pointers.
> 
> You've failed to fix the sense of the above...

The sense still is correct.
