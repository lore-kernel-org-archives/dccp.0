From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Date: Fri, 28 Sep 2007 15:25:58 +0000
Subject: Re: DCCP support in VLC
Message-Id: <200709281825.58935.rdenis@simphalempin.com>
List-Id: <dccp.vger.kernel.org>
References: <200709271930.03854.rdenis@simphalempin.com>
In-Reply-To: <200709271930.03854.rdenis@simphalempin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Le Friday 28 September 2007 14:33:51 Gerrit Renker, vous avez écrit :
> When the Reset closing the connection arrives, the same shutdown mask is
> set as in TCP. What I thus think you could do as a
> test-for-end-of-connection is to test whether the socket descriptor is
> still read/writeable.

If it works like TCP, shutdown-for-recv will make the socket always readable, 
and will not affect writeability at all, since the sending half may still be 
open. As such, I don't think it will solve the problem.

Currently, I am assuming that length = 0 means end-of-connection, because I 
only use RTP/RTCP, so zero bytes is not a valid packet length. But that's a 
little bit ugly.

Other than that, and apart from pending DCCP service code support I am happy 
to announce that the official VLC development tree now support DCCP 
out-of-the-box with RTP.

Manually, on the sender (assuming sender IP is 2001:db8::1):
$ vlc -vv /dev/dvd \
--sout '#rtp{dccp,mux=ts,portP04}'

On the receiver:
$ vlc -vv dccp://[2001:db8::1]:5004

Or advertized with SAP, on the sender:
$ vlc -vv /dev/dvd \
--sout '#rtp{dccp,mux=ts,portP04,dst 01:db8::1,sdp=sap,name=MyDVD}'

On the receiver, enable SAP service discovery and click MyDVD from the 
playlist.


We cannot support multiple streams per session, because the live555 library 
does not support DCCP at this time. But TS multiplexing works great anyway.

Thanks for your help!

-- 
Rémi Denis-Courmont
http://www.remlab.net/
