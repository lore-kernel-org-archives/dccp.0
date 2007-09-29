From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 29 Sep 2007 16:52:42 +0000
Subject: Re: DCCP support in VLC
Message-Id: <200709291752.42382@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709271930.03854.rdenis@simphalempin.com>
In-Reply-To: <200709271930.03854.rdenis@simphalempin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > When the Reset closing the connection arrives, the same shutdown mask is
|  > set as in TCP. What I thus think you could do as a
|  > test-for-end-of-connection is to test whether the socket descriptor is
|  > still read/writeable.
|  
|  If it works like TCP, shutdown-for-recv will make the socket always readable, 
|  and will not affect writeability at all, since the sending half may still be 
|  open. As such, I don't think it will solve the problem.
DCCP has no half-close (RFC 4340, 4.6), so closing the socket shuts down both the
read and the write end (i.e. SHUT_RDWR is set by the kernel) - you could test for this.

|  Currently, I am assuming that length = 0 means end-of-connection, because I 
|  only use RTP/RTCP, so zero bytes is not a valid packet length. But that's a 
|  little bit ugly.
It would be better to use a different solution. There has also been discussion to use
0-sized packets for keep-alive or congestion messages (I hope that this remains talk only).
