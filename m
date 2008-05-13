From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 May 2008 13:46:31 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080513134631.GA7024@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| 
| DCCP clearly fails the POSIX definition of SOCK_DGRAM in different ways.
| 
| I think this is not a good idea.
| 
Thanks for the clarification. Even in Posix, datagram = connection-less.
Plus the issues with older kernel releases. Question resolved, no SOCK_DGRAM.


| > It also relieves the libc writers from having to support another socket
| > type.
| 
| As long as SOCK_DCCP-or-whatever is not automatically selected when
| ai_socktype is nul, this should be both easy to implement in libc *and*
| backward compatible (applications will not try to use DCCP implicitly).
| 
There are two possibilities:
 * as additional supported protocol (there are many new transport
   protocols, perhaps there is some kind of modular support),
 * if DCCP service codes are part of the lookup, then getting library
   support can take longer (algorithm changes).

Both may take a while until available. In the meantime it would be good
to find some smart workaround for getaddrinfo, as changes in the internals
so far required to fix applications several times.
