From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 07:02:03 +0000
Subject: Re: [PATCH 0/4] Fix check for incorrect or missing sequence mumbers
Message-Id: <20080725070203.GC5735@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <488840B1.5070303@cn.fujitsu.com>
In-Reply-To: <488840B1.5070303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Agree, I will fix the patch. I think she header size of 8 may be caome  
> from the tcp code^_^?
Yes, it is the same in tcp_v4_err() in net/ipv4/tcp_ipv4.c and I think
that is because of RFC 1122, 3.2.2: 
 "Every ICMP error message includes the Internet header and at
  least the first 8 data octets of the datagram that triggered
  the error; more than 8 octets MAY be sent; this header and data
  MUST be unchanged from the received datagram."

In TCP it is possible to get at the sequence number with the first 8
octets, in DCCP this is at least 12 bytes as correctly pointed out by
your patch changelog.
