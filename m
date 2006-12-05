From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 05 Dec 2006 11:03:18 +0000
Subject: Re: CCID3 performance / checksum profiling
Message-Id: <20061205110318.GA3494@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <200612051053.01848@strip-the-willow>
In-Reply-To: <200612051053.01848@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Dec 05, 2006 at 10:53:01AM +0000, Gerrit Renker wrote:
> There used to be a similar situation in UDP, until people checksummed and copied at the
> same time (see Partridge/Pink "A faster UDP", TON 1993). 

Actually this reminds me of a totally off-topic thing, but same concept.
h1kari's wep cracker was fast at the time because, among other things, it would
also decrypt data and calculate the CRC32 at the same time in one pass, thus,
not having to scan the buffer twice.  I totally agree that since you are copying
the buffer from user -> kernel anyway, you might as well calculate the checksum.

> Using partial checksums may give performance close to the copy_and_checksum case, since
> in the extreme case only the header is checksummed - and this has to be done irrespective
> of which copy function is used.

I think header checksums will be a big win.  Immagine high frequency jumbo
frames.  Also, in real life, I don't know how easy it is to corrupt packets.  I
think the typical scenario is packet loss.  In practice, many MACs have their
own checksums anyway.

> |  http://darkircop.org/check.png
> This is very interesting to see but I could not tell what the axes were for - do higher
> numbers mean better relative performance or the other way around?

It's an awful graph yes; it was a quick drawing i did to show my boss.  x-axis
is packet size, y-axis is checksums per second [x1000].  it's running the i386
checksum code in userland.  The linux emulation curve is actually a freebsd box
running the linux checksum binary via linux emulation.

Basically, from that plot intel sucks =D  That said, we weren't using the latest
Xeons with a shorter pipeline.  It's probably some weirdness in the branch
predictions and instruction pipeline.  Dunno; didn't investigate further.
