From: Ido Schimmel <idosch@idosch.org>
Date: Mon, 27 Jul 2020 13:33:31 +0000
Subject: Re: [PATCH 19/26] net/ipv6: switch ipv6_flowlabel_opt to sockptr_t
Message-Id: <20200727133331.GA1851348@shredder>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-20-hch@lst.de>
In-Reply-To: <20200723060908.50081-20-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Jul 27, 2020 at 03:00:29PM +0200, Christoph Hellwig wrote:
> On Mon, Jul 27, 2020 at 03:15:05PM +0300, Ido Schimmel wrote:
> > I see a regression with IPv6 flowlabel that I bisected to this patch.
> > When passing '-F 0' to 'ping' the flow label should be random, yet it's
> > the same every time after this patch.
> 
> Can you send a reproducer?

```
#!/bin/bash

ip link add name dummy10 up type dummy

ping -q -F 0 -I dummy10 ff02::1 &> /dev/null &
tcpdump -nne -e -i dummy10 -vvv -c 1 dst host ff02::1
pkill ping

echo

ping -F 0 -I dummy10 ff02::1 &> /dev/null &
tcpdump -nne -e -i dummy10 -vvv -c 1 dst host ff02::1
pkill ping

ip link del dev dummy10
```

Output with commit ff6a4cf214ef ("net/ipv6: split up
ipv6_flowlabel_opt"):

```
dropped privs to tcpdump
tcpdump: listening on dummy10, link-type EN10MB (Ethernet), capture size 262144 bytes
16:26:27.072559 62:80:34:1d:b4:b8 > 33:33:00:00:00:01, ethertype IPv6 (0x86dd), length 118: (flowlabel 0x920cf, hlim 1, next-header ICMPv6 (58) payload length: 64) fe80::6080:34ff:fe1d:b4b8 > ff02::1: [icmp6 sum ok] ICMP6, echo request, seq 2
1 packet captured
1 packet received by filter
0 packets dropped by kernel

dropped privs to tcpdump
tcpdump: listening on dummy10, link-type EN10MB (Ethernet), capture size 262144 bytes
16:26:28.352528 62:80:34:1d:b4:b8 > 33:33:00:00:00:01, ethertype IPv6 (0x86dd), length 118: (flowlabel 0xcdd97, hlim 1, next-header ICMPv6 (58) payload length: 64) fe80::6080:34ff:fe1d:b4b8 > ff02::1: [icmp6 sum ok] ICMP6, echo request, seq 2
1 packet captured
1 packet received by filter
0 packets dropped by kernel
```

Output with commit 86298285c9ae ("net/ipv6: switch ipv6_flowlabel_opt to
sockptr_t"):

```
dropped privs to tcpdump
tcpdump: listening on dummy10, link-type EN10MB (Ethernet), capture size 262144 bytes
16:32:17.848517 f2:9a:05:ff:cb:25 > 33:33:00:00:00:01, ethertype IPv6 (0x86dd), length 118: (flowlabel 0xfab36, hlim 1, next-header ICMPv6 (58) payload length: 64) fe80::f09a:5ff:feff:cb25 > ff02::1: [icmp6 sum ok] ICMP6, echo request, seq 2
1 packet captured
1 packet received by filter
0 packets dropped by kernel

dropped privs to tcpdump
tcpdump: listening on dummy10, link-type EN10MB (Ethernet), capture size 262144 bytes
16:32:19.000779 f2:9a:05:ff:cb:25 > 33:33:00:00:00:01, ethertype IPv6 (0x86dd), length 118: (flowlabel 0xfab36, hlim 1, next-header ICMPv6 (58) payload length: 64) fe80::f09
a:5ff:feff:cb25 > ff02::1: [icmp6 sum ok] ICMP6, echo request, seq 2
1 packet captured
1 packet received by filter
0 packets dropped by kernel
```

> 
> > 
> > It seems that the pointer is never advanced after the call to
> > sockptr_advance() because it is passed by value and not by reference.
> > Even if you were to pass it by reference I think you would later need to
> > call sockptr_decrease() or something similar. Otherwise it is very
> > error-prone.
> > 
> > Maybe adding an offset to copy_to_sockptr() and copy_from_sockptr() is
> > better?
> 
> We could do that, although I wouldn't add it to the existing functions
> to avoid the churns and instead add copy_to_sockptr_offset or something
> like that.

Sounds good

Thanks
