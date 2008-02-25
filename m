From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 25 Feb 2008 19:43:08 +0000
Subject: Fwd: [dccp] DCCP-TP Release 0.00 available
Message-Id: <5640c7e00802251143q523aea80o81805be682c90060@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

---------- Forwarded message ----------
From: Phelan, Tom <tphelan@sonusnet.com>
Date: Tue, Feb 26, 2008 at 7:40 AM
Subject: [dccp] DCCP-TP Release 0.00 available
To: 'dccp' working group <dccp@ietf.org>


Hi All,

DCCP-TP is a fresh-start implementation of DCCP optimized for
portability that I have been working on.  The code is at a very early
beta stage of development, but I felt that it was best to get it out to
other eyes before the next IETF meeting, so I'm making it available now.
There is a wiki with source downloads, documentation and a discussion
forum at http://www.phelan-4.com/dccp-tp/.  Please check it out :-).

R0.00 implements the main DCCP spec plus CCID 2 with IPv4 DCCP-NAT
encapsulation.  IPv6 and DCCP-RAW encapsulation can be added easily (and
will be real soon now :-)), but debugging was easier with DCCP-NAT since
it could be done in user space without root privileges.

DCCP-TP is meant to be portable, but at the current time there is only
port.  This port supports running DCCP-TP and the applications that use
it as a single Linux process with Pthreads.

I hope that having a second, completely independent, implementation of
DCCP will help us make progress in interoperability issues, and that an
implementation optimized for portability will allow us to make use
environments outside of Linux, especially embedded systems.

The external, API, aspects of DCCP-TP are quite raw right now, but I
have tried to pay close attention to the internal implementation of DCCP
and believe that it is fairly feature-rich and conforms to the latest
specs as best as I can interpret them.  Any feedback, either through
this list, through the discussion forum at
http://www.phelan-4.com/dccp-tp/ or directly to me will be greatly
appreciated.

Tom P.

PS.     The CCID 2 code currently has some sort of memory corruption bug
that I haven't been able to track down.  It normally doesn't make itself
felt until the socket is destroyed, so there's quite a bit of DCCP that
works and can be used.  Any help finding the problem will win a free
beer next time we can get together :-).



-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
