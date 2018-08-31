From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 31 Aug 2018 14:00:21 +0000
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <CAK8P3a00DLR9JyfKwbYXnKCpRf+YWuUyMbC+UfXZTfdnAJxRtg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20180829130308.3504560-1-arnd@arndb.de>
In-Reply-To: <20180829130308.3504560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Aug 31, 2018 at 3:38 PM Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Fri, Aug 31, 2018 at 6:31 AM Arnd Bergmann <arnd@arndb.de> wrote:
> > On Thu, Aug 30, 2018 at 10:10 PM Willem de Bruijn
> > <willemdebruijn.kernel@gmail.com> wrote:
> > > On Wed, Aug 29, 2018 at 9:05 AM Arnd Bergmann <arnd@arndb.de> wrote:
> > > If this is the only valid implementation of .gettstamp, the indirect
> > > call could be avoided in favor of a simple branch.
> >
> > I thought about that as well, but I could not come up with a
> > good way to encode the difference between socket protocols
> > that allow timestamping and those that don't.
> >
> > I think ideally we would just call sock_gettstamp() unconditonally
> > on every socket, and have that function decide whether timestamps
> > make sense or not. The part I did not understand is which ones
> > actually want the timestamps or not. Most protocols that
> > implement the ioctls also assign skb->tstamp, but there are some
> > protocols in which I could not see skb->tstamp ever being set,
> > and some that set it but don't seem to have the ioctls.
>
> These probably only use cmsgs SCM_TIMESTAMP(NS|IMG)
> to read timestamps.

Good point. FWIW, I have discussed with Deepa how those should
be modified for y2038, but we don't have any current patches for
those.

> > Looking at it again, it seems that sock_gettstamp() should
> > actually deal with this gracefully: it will return a -EINVAL
> > error condition if the timestamp remains at the
> > SK_DEFAULT_STAMP initial value, which is probably
> > just as appropriate (or better) as the current -ENOTTY
> > default, and if we are actually recording timestamps, we
> > might just as well report them.
>
> Yes, that's a nice solution. There is always some risk in changing
> error codes. But ioctl callers should be able to support newly
> implemented functionality. Even if partially implemented and
> returning ENOENT instead of ENOIOCTLCMD.

Ok, so do you think we should stay with the current version
for now, and change the two points later, or should I rework
it to integrate the locking and removing the callback?

I suppose the series actually gets nicer without the
callback, since I can simply add the generic timestamping
implementation first, and then remove the dead ioctl
handlers.

        Arnd
