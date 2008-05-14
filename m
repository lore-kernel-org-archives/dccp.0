From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Date: Wed, 14 May 2008 17:47:40 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <200805142047.40726.rdenis@simphalempin.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Le Tuesday 13 May 2008 22:14:07 Ulrich Drepper, vous avez écrit :
> Rémi Denis-Courmont wrote:
> > In any case, getaddrinfo() should be patched to
> > [...]
>
> What should be the behavior is socktype and protocol are zero?  Should
> these two types be returned by default?  What others?  So far we return
> TCP, UDP, and raw socket information.  I'd rather keep the list short
> but since we already have raw sockets in there (because they are in
> POSIX) I won't reject anything that's more useful than raw sockets.

Well... I've always wondered what the use of both zeroes was supposed to be.

In AI_PASSIVE mode, it makes no sense, since there is no way you can handle 
passive SOCK_STREAM sockets (bind+listen+accept) and "passive" SOCK_DGRAM 
sockets in any common way (bind+recvfrom+sendto).

Even in active mode (connect+send), I cannot figure out how to share 
SOCK_STREAM code with SOCK_DGRAM code, given the incompatible end-of-file and 
datagram boundaries semantics (or lack thereof).

Hence, it seems that both zeroes is only of use to enumerate the supported 
protocol (yeah right...). If that's so adding DCCP and even UDP-Lite would be 
OK, even though they are corner-case protocols. Do you intend to 
implement "dccp" when parsing /etc/services, though?

Frankly, I have no definite answer, and I'm not any kind of standard body to 
make one in the first place :P

-- 
Rémi Denis-Courmont
http://www.remlab.net/
