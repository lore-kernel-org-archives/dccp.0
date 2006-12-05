From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 10:53:01 +0000
Subject: Re: CCID3 performance / checksum profiling
Message-Id: <200612051053.01848@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Andrea Bittau:

|  * the most expensive thing should be checksum calculating [~25%]. 
I have thought about it and I think the main reason is that DCCP first assembles
the packet (copy from user, add header) and checksums only after all that work
has been done. 

|  * After checksum calculation, the profile should be flat.  That is, 100000
|    functions, each taking 0.1%.
There used to be a similar situation in UDP, until people checksummed and copied at the
same time (see Partridge/Pink "A faster UDP", TON 1993). 

The kernel has csum_partial_copy_fromiovecend() which is used e.g. by ip_generic_frag.
The challenge/difficulty of using this function with partial checksums is in telling it to

  * copy `len' bytes from user

  * checksum cscov <= len bytes 
    (i.e. continue copying, but stop checksumming after cscov bytes)

  * it leaves the checksum in skb->csum as before

If someone can find a way of adding this, including respecting 4-byte boundaries, it
may improve performance by some degree. In this case, I would like to hear about that,
since a similar case arises in UDP-Lite (RFC 3828).

Using partial checksums may give performance close to the copy_and_checksum case, since
in the extreme case only the header is checksummed - and this has to be done irrespective
of which copy function is used.

|  Regarding checksums, have a look at:
|  http://darkircop.org/check.png
This is very interesting to see but I could not tell what the axes were for - do higher
numbers mean better relative performance or the other way around?
