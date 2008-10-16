From: "Leandro Sales" <leandroal@gmail.com>
Date: Thu, 16 Oct 2008 21:09:37 +0000
Subject: Re: Protocol not attached
Message-Id: <5bc4c4570810161409k609df800m2acc9a5adf70e325@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, Oct 13, 2008 at 2:51 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrot=
e:
>
> Hi Leandro
> |
> |    After boot the following dccp modules were loaded:
> |    Module                  Size  Used by
> |    dccp_tfrc_lib          17868  0
> |    dccp_ipv6              14916  2
> |    dccp_ipv4              14596  3 dccp_ipv6
> |    dccp                   58112  2 dccp_ipv6,dccp_ipv4
> |
> |    I run iperf and that error message appeared again. I then did what A=
rnaldo
> |    suggested: I loaded dccp_ccid2 using modprobe, but iperf shows the s=
ame
> |    error message. I ran iperf using strace com o 2.6.27-rc8:
> Unfortunately, loading just dccp_ccid2 is not sufficient to diagnose:
> the feature-negotiation code preloads all CCID modules that it is going
> to advertise to the peer.
>
> I can not find an error in the strace below. What I am asking is whether
> the fault is due to
>  (1) a module loadin problem in general or
>  (2) whether this problem is specific to DCCP.
>
> Can you please check again -- thanks.
>
> Gerrit
> |
> |    strace -f -e trace=3Dnetwork iperf -s -d -l 1424 -1
> |    Process 4374 attached
> |    Process 4375 attached
> |    [pid  4374] socket(PF_INET, 0x6 /* SOCK_??? */, IPPROTO_IP) =3D 3
> |    [pid  4374] setsockopt(3, 0x10d /* SOL_?? */, 2, [1179796816], 4) =
=3D 0
> |    [pid  4374] setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> |    [pid  4374] bind(3, {sa_family=AF_INET, sin_port=3Dhtons(5001),
> |    sin_addr=3Dinet_addr("MailScanner warning: numerical links are often
> |    malicious: 0.0.0.0")}, 16) =3D 0
> |    [pid  4374] listen(3, 5)                =3D 0
> |    [pid  4374] accept(3,  <unfinished ...>
> |    [pid  4375] getsockopt(3, SOL_SOCKET, SO_RCVBUF, [106496], [4]) =3D 0

Hello Gerrit,

I tried to be more precise.

I run the same kernel in two very similar computers, in one computer
it works perfect, in another one, not. Maybe this problem is happening
due to miss-configuring in the computer that occurs this error. In all
the case, I have here de .config for both machines (kernel 2.6.27-rc8)
and the complete strace.log for both execution. If you'd like to
analyze them I can send you. Please let me know in case that you want
me to send you the configs and strace log files.

Regards,
Leandro.
