From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 26 May 2008 21:40:53 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200805262340.53355.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 26 of May 2008, Gerrit Renker napisa=B3:
> | I have nothing against creating generic interface for obtaining
> | information about various aspects of dccp. But I can't see how netlink
> | can help us here. From the documents I've read I understand that generic
> | netlink requires you to create a special kind of socket type and then y=
ou
> | can send or receive information through it. But it seems to be something
> | separate from dccp sockets.
>
> Yes, the netlink socket would be different from the DCCP socket and it
> is actually a good point - it shows that this interface can only be used
> for global parameters or settings. Or maybe there is a way of
> associating both sockets.
>
I haven't seen any. But I'm quite new to kernel development (and to netlink=
 in=20
particular).

> | As for information we can get from kernel wrt dccp we have at least:
> | 1. fixed information that depends only on kernel version. For example
> | list of ccids, list of available qpolicies, list of parameters for given
> | qpolicy, etc. These are system wide and don't need reference to socket.
> | These could even be exposed by read-only entries in /sys or /proc.
>
> That is a good point - I think Arnaldo had a similar idea once for
> implenting system-wide policies regarding which CCIDs are supported.
> Something like net.ipv4.tcp_available_congestion_control.
>
Ok, we may go this way. I'll try to write a patch in a few days (quite busy=
=20
now).

> | 3. statistics. These are not options in the sense that you cannot set
> | them. You also cannot expect that two consecutive reads will return the
> | same value. They depend on certain asynchronous events in various parts
> | of dccp code. The first question is: should we pass those raw events to
> | applications (such as "prio qpolicy: packet dropped") or aggregate data
> | ("in the last 100 packets 17 were dropped before sending")? For this ki=
nd
> | of information we need reference to socket (struct sock *). And I can't
> | see how we could obtain it from functions not mentioned in struct proto.
>
> It was for this part that I looked at netlink. This goes into the
> direction of a new API or at least API extensions.
>=20
We basically need a callback from code that can access struct sock...

> (...)
> For per-socket statistics there is indeed a need for a notification
> mechanism. If a synchronous mechanism is sufficient, then something like
> the current CCID-3 getsockopt(DCCP_SOCKOPT_CCID_{RX,TX}_INFO) can be used.
>
Synchronous mechanism is acceptable but callback (at least as an option) wo=
uld=20
be way nicer.

> For asynchronous notification, using a special signal comes to mind,
> where the application installs a signal handler as notifier.
>
We'd have to pass affected socket identifier (process may use more than one=
=20
socket). To me it looks like a not-so-nice hack. But still I don't have=20
better ideas on how to implement asynchronous event notification (callback)=
.=20
Ok, but if we are at hackish ideas what about this one: use dccp_ioctl to=20
wait on a mutex. If an event occurs we release mutex thus allowing dccp_ioc=
tl=20
to finish execution and consequently informing user that something=20
interesting has just happened - what it exactly is would have to be=20
determined by other means.

> The best that I can think of is to map a segment of userspace memory
> into the kernel and use this memory area as a (ready-only) statistics
> struct. That would save the system call overhead of using getsockopt().
>
I don't think the syscall overhead is big enough to care. After all you don=
't=20
need statistics that often. Shared memory creates potential problems with=20
synchronization (ok, it is read-only but you need to provide consistent=20
data). Plus you must update them whether needed or not because you never kn=
ow=20
when the user will want to read them (it may be a problem in some scenarios=
=20
and may not be a problem in others). IMO more problems that it's worth.
--=20
Regards,
Tomasz Grobelny
