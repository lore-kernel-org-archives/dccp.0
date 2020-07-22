From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Wed, 22 Jul 2020 17:09:41 +0000
Subject: Re: get rid of the address_space override in setsockopt
Message-Id: <CAADnVQKy0+rsRftEzp4PvxQtj7uOwybz0Nd4_h0FR37p2Q=X4w@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Jul 22, 2020 at 12:56 AM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Jul 20, 2020 at 01:47:56PM -0700, Alexei Starovoitov wrote:
> > > a kernel pointer.  This is something that works for most common sockopts
> > > (and is something that the ePBF support relies on), but unfortunately
> > > in various corner cases we either don't use the passed in length, or in
> > > one case actually copy data back from setsockopt, so we unfortunately
> > > can't just always do the copy in the highlevel code, which would have
> > > been much nicer.
> >
> > could you rebase on bpf-next tree and we can route it this way then?
> > we'll also test the whole thing before applying.
>
> The bpf-next tree is missing all my previous setsockopt cleanups, so
> there series won't apply.

Right. I've realized that after sending that email two days ago.
Now bpf-next->net-next PR is pending and as soon as it's merged
bpf-next will have all the recent bits.
