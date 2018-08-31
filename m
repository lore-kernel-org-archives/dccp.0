From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri, 31 Aug 2018 15:08:09 +0000
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <CAF=yD-+tiVeP0FA1CUrT4Jyn28tnT+bett+Dq2frvU5eS1ANPw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20180829130308.3504560-1-arnd@arndb.de>
In-Reply-To: <20180829130308.3504560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> > > Looking at it again, it seems that sock_gettstamp() should
> > > actually deal with this gracefully: it will return a -EINVAL
> > > error condition if the timestamp remains at the
> > > SK_DEFAULT_STAMP initial value, which is probably
> > > just as appropriate (or better) as the current -ENOTTY
> > > default, and if we are actually recording timestamps, we
> > > might just as well report them.
> >
> > Yes, that's a nice solution. There is always some risk in changing
> > error codes. But ioctl callers should be able to support newly
> > implemented functionality. Even if partially implemented and
> > returning ENOENT instead of ENOIOCTLCMD.
>
> Ok, so do you think we should stay with the current version
> for now, and change the two points later, or should I rework
> it to integrate the locking and removing the callback?
>
> I suppose the series actually gets nicer without the
> callback, since I can simply add the generic timestamping
> implementation first, and then remove the dead ioctl
> handlers.

Agreed. I would add the locks in a separate patch, if only on the
off-chance that lockdep discovers something and it will be easier
to bisect and revise independently. I can also follow up with that
patch outside this set, of course.
