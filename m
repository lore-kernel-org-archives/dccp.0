From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 15 Nov 2007 07:02:43 +0000
Subject: Re: How much is available for reading on the socket?
Message-Id: <20071115070243.GA5654@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
In-Reply-To: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > > Arnaldo wrote a patch which realises SIOCINQ (it is in 2.6.24-rc1/2).
| >
| > And, on Linux:
| >
| > include/linux/sockios.h
| >
| > /* Linux-specific socket ioctls */
| > #define SIOCINQ         FIONREAD
| >
| > - Arnaldo
| >
| 
| And I'm using this on the gstreamer plugin and it is working ok.
| 
So that other people not have to make the same mistake as me and mistake
SIOCINQ and FIONREAD, I have patched an update to
Documentation/networking/dccp.tx (next email).

Have you got the sources available for the DCCP plugin: it would be 
interesting to see how it is used. After the handshake ioctl(FIONREAD)
returns 0 for a while, and same after last read.

If done intelligently, this could solve the End-of-File problem reported 
earlier by Remi Denis-Courmont.
