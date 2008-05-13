From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 May 2008 07:28:53 +0000
Subject: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

There is an API and an address resolution problem involved in specifying a
separate/distinct socket type `SOCK_DCCP'.

The problem is that the default getaddrinfo(3) does not support the `alien'
SOCK_DCCP socket type (it returns `ai_socktype not supported'), thus requiring
various cheats/work-arounds in order to bring up a DCCP socket on a dual-stack
host.

In order to get an address at all,
 * a hint with an ai_socktype=SOCK_DGRAM or SOCK_STREAM needs to be supplied;
 * using ai_socktype=0 causes IPv4 addresses to be returned first, so that a
   server on a dual-stack host needs to be coaxed into v6 mode to accept
   incoming v6 connections.

The suggestion therefore is to not use a separate SOCK_DCCP socket type,
and to put DCCP up under SOCK_DGRAM (being in fact datagram-based), i.e.

	socket(sd, SOCK_DCCP, 0);	

is replaced by	
	
	socket(sd, SOCK_DGRAM, IPPROTO_DCCP);


Having also seen the work-arounds in programs that other people wrote,
I believe that the above change will make it in the long term easier for
people to write DCCP-enabled applications.

It also relieves the libc writers from having to support another socket type.

A quick look at SCTP shows that they also did not introduce new socket types,
relying on the existing SOCK_STREAM/SOCK_SEQPACKET ones.

It might be still early enough to resolve this, before it is widely used
and can then only be supported via work-arounds.

I can't see a disadvantage here and the only work required is to update that
datagram-based not automatically means connection-less.

Is there support for this change or are there reasons to keep SOCK_DCCP?
