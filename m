From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Oct 2008 14:51:06 +0000
Subject: Re: Protocol not attached
Message-Id: <20081013145106.GA3644@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Leandro
|=20
|    After boot the following dccp modules were loaded:
|    Module                  Size  Used by
|    dccp_tfrc_lib          17868  0
|    dccp_ipv6              14916  2
|    dccp_ipv4              14596  3 dccp_ipv6
|    dccp                   58112  2 dccp_ipv6,dccp_ipv4
|=20
|    I run iperf and that error message appeared again. I then did what Arn=
aldo
|    suggested: I loaded dccp_ccid2 using modprobe, but iperf shows the same
|    error message. I ran iperf using strace com o 2.6.27-rc8:
Unfortunately, loading just dccp_ccid2 is not sufficient to diagnose:
the feature-negotiation code preloads all CCID modules that it is going
to advertise to the peer.=20

I can not find an error in the strace below. What I am asking is whether
the fault is due to=20
 (1) a module loadin problem in general or
 (2) whether this problem is specific to DCCP.

Can you please check again -- thanks.

Gerrit
|=20
|    strace -f -e trace=3Dnetwork iperf -s -d -l 1424 -1
|    Process 4374 attached
|    Process 4375 attached
|    [pid  4374] socket(PF_INET, 0x6 /* SOCK_??? */, IPPROTO_IP) =3D 3
|    [pid  4374] setsockopt(3, 0x10d /* SOL_?? */, 2, [1179796816], 4) =3D 0
|    [pid  4374] setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
|    [pid  4374] bind(3, {sa_family=AF_INET, sin_port=3Dhtons(5001),
|    sin_addr=3Dinet_addr("MailScanner warning: numerical links are often
|    malicious: 0.0.0.0")}, 16) =3D 0
|    [pid  4374] listen(3, 5)                =3D 0
|    [pid  4374] accept(3,  <unfinished ...>
|    [pid  4375] getsockopt(3, SOL_SOCKET, SO_RCVBUF, [106496], [4]) =3D 0
