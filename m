From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 14 May 2008 18:00:11 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080514180011.GA1661@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > But either is important be considered when a user unambiguously specifies
| > ai_socktype and/or ai_protocol; to avoid bad/brittle workarounds.
| 
| OK, I added the support.  Will be in glibc 2.9.
| 
This is really good news :)

| But what about $subject?  What is the story with SOCK_DCCP?  I added it
| now but if it's going away I'd rather remove it.
| 
No, I don't think it will be deprecated, it has been part of several kernel
releases in this form already and there was no support in the thread for
changing SOCK_DCCP.

AS I am guilty of $subject, the story is that the initial suggestion to
avoid the trouble with getaddrinfo() by changing the socket type to
SOCK_DGRAM, since then presumably an address would be returned. 

This proved an even poorer workaround than any of the existing ones, in
particular since it collides with the (Posix) definition of SOCK_DGRAM,
and has been part of kernel releases.

Eventually Arnaldo made the most sensible suggestion of why not solving
the trouble at the root and update glibc, which is how a message with
this subject reached your inbox. This had wider support and I can't
think of a better way to solve the problem. 

Hence many thanks indeed, as the absence of proper DCCP/UDP-Lite support
in getaddrinfo() has so far caused quite some grief/frustration.

Gerrit
