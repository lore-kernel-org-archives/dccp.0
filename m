From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 07:54:27 +0000
Subject: Re: [PATCH 1/1] [DCCP]: Fix default sequence window size
Message-Id: <20060622075427.GA1390@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <449A1199.1080404@jandi.co.nz>
In-Reply-To: <449A1199.1080404@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> As a side effect of this my rx speed using iperf goes from about 2.8 
> Mbits/sec to 3.5. This is still far too slow but it is a step in the 
> right direction.

I got a bunch of fixes i need to commit.  I'll try to send out patches this
week.  They should make things go faster.  What is your test setup like?

I was able to do 1Gb/s with 0rtt.  As soon as I add delay with netem, I could
only do ~75Mbit/s.  Still investigating why.

Also make sure you change the socket buffer wmem sysctl.
