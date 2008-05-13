From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 May 2008 17:03:25 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080513170325.GB11499@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > the existing stuff alone, and then requiring programs that want to use
| > getaddrinfo to use it that way?
| 
| I wonder what is the problem with doing what I did when adding support
| for DCCP in ttcp, or for AF_LLC in ssh, ncftp, vsftpd, etc, i.e.
| getaddrinfo/getnameinfo wrappers that look if SOCK_DCCP or AF_LLC are
| being asked for and doing the right thing.
| 
Using work-arounds is brittle and frustrating when the API behaviour
suddenly changes. My experience of using such a wrapper was:

 * it passed UDP(-Lite), TCP through without changing the socket type;
 * when passed DCCP, it set the socket type to 0, to avoid `ai_socktype
   not supported' getaddrinfo error;
 * this used to work fine until about January, when something in the
   lookup machinery for dual-stack hosts changed:
   - before, AF_UNSPEC + ai_socktype=0 put IPv6 first into the result list,
   - now the the result order is reversed (IPv4 sockets are returned first)
 * so maybe "pretending to be UDP" (ai_socktype=SOCK_DGRAM) is a better
   workaround (at least it worked until this afternoon :)


| What would be the problem of SOCK_DCCP being handled in glibc in such a
| fashion?
That is probably the best and most robust solution one can think of.

Even the suggestion of changing to SOCK_DGRAM+IPPROTO_DCCP is just another
work-around and, as David and Remi confirmed, a bad one at that.

Gerrit
