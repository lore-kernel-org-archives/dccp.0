From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Jun 2008 10:21:36 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080602102136.GB10306@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > It was for this part that I looked at netlink. This goes into the
| > direction of a new API or at least API extensions.
| > 
| We basically need a callback from code that can access struct sock...
| 
| > (...)
| > For per-socket statistics there is indeed a need for a notification
| > mechanism. If a synchronous mechanism is sufficient, then something like
| > the current CCID-3 getsockopt(DCCP_SOCKOPT_CCID_{RX,TX}_INFO) can be used.
| >
| Synchronous mechanism is acceptable but callback (at least as an option) would 
| be way nicer.
| 
I have been looking around for alternatives - there are some
very good solutions for such aspects in the SCTP subsystem. 

They implement the subscription of event notifications on a socket for
all sorts of events.

A socket option performs this subscription, notifications are then passed
along with data (I think also without, have not dug deep enough into the
sources), via recvmsg(). This is the inverse path to qpolicies: the
ancillary data is passed via cmsg(3) wrappers to the user.

To distinguish events from normal (ancillary) data, SCTP sets the
flag fields to MSG_NOTIFICATION.

There are two good papers on this (the second one is a bit older):
http://www.bsdcan.org/2008/schedule/events/91.en.html
http://lwn.net/2001/features/OLS/pdf/pdf/sctp.pdf

The sources are in net/sctp, the lksctp project is hosted at
http://sourceforge.net/projects/lksctp

I think that this approach is elegant and has something to offer for
DCCP as well. What do you think?

| Ok, but if we are at hackish ideas what about this one: use dccp_ioctl to 
| wait on a mutex. If an event occurs we release mutex thus allowing dccp_ioctl 
| to finish execution and consequently informing user that something 
| interesting has just happened - what it exactly is would have to be 
| determined by other means.
| 
I am trying to think in terms of how much documentation this would need
in order to explain to someone how to use it. It seems feasible, but to
me a bit complicated.


| > The best that I can think of is to map a segment of userspace memory
| > into the kernel and use this memory area as a (ready-only) statistics
| > struct. That would save the system call overhead of using getsockopt().
| >
| I don't think the syscall overhead is big enough to care. After all you don't 
| need statistics that often. Shared memory creates potential problems with 
| synchronization (ok, it is read-only but you need to provide consistent 
| data). Plus you must update them whether needed or not because you never know 
| when the user will want to read them (it may be a problem in some scenarios 
| and may not be a problem in others). IMO more problems that it's worth.
Yes that was why I had reservations against using the ringbuffer API by Lai/Kohler
(implemented for TCP in	http://heim.ifi.uio.no/paalh/publications/files/ism07.pdf ).

We could consider this for later, but it does not seem easy to do this
both in a safe and in a non-complicated way.
