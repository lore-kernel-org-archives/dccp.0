From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 13 May 2008 16:23:25 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080513162325.GF15306@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, May 13, 2008 at 08:50:59AM -0700, David Stevens escreveu:
> Are they mutually exclusive?
> 
> Why not add SOCK_DGRAM/IPPROTO_DCCP support while leaving

Because DCCP is not SOCK_DGRAM at all? :)

> the existing stuff alone, and then requiring programs that want to use
> getaddrinfo to use it that way?

I wonder what is the problem with doing what I did when adding support
for DCCP in ttcp, or for AF_LLC in ssh, ncftp, vsftpd, etc, i.e.
getaddrinfo/getnameinfo wrappers that look if SOCK_DCCP or AF_LLC are
being asked for and doing the right thing.

IIRC at the time I asked Ulrich Drepper about adding support for PF_LLC
sockets in glibc and he said that it would be OK as long as it didn't
included PF_LLC sockets in the default search, doing it only when PF_LLC
was explicitely passed. I just never got around to actually cook up the
patches and send it to Uli.

What would be the problem of SOCK_DCCP being handled in glibc in such a
fashion?

- Arnaldo
