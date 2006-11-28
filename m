From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Nov 2006 22:03:29 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <5640c7e00611281403q63e22d63p1253beb322768e61@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> ttcp-r: accept from localhost.ghostprotocols.net
> ttcp-t: connect
> ttcp-t: 256000 bytes in 22.98 real seconds = 10.88 KB/sec +++
> ttcp-t: 1000 I/O calls, msec/call = 23.53, calls/sec = 43.51
> ttcp-t: 0.2user 17.0sys 0:22real 75% 0i+0d 0maxrss 0+1pf 0+1000csw
> ttcp-r: 256000 bytes in 23.31 real seconds = 10.73 KB/sec +++
> ttcp-r: 1001 I/O calls, msec/call = 23.84, calls/sec = 42.95
> ttcp-r: 0.1user 5.0sys 0:23real 22% 0i+0d 0maxrss 0+1pf 1001+6csw
>
Umm.... that performance sucks - were you doing that with netem in
middle or something?

I'll test tomorrow but that doesn't look good - means we might have regressed...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
