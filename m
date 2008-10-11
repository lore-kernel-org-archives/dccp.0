From: "Leandro Sales" <leandroal@gmail.com>
Date: Sat, 11 Oct 2008 17:28:58 +0000
Subject: Re: Protocol not attached
Message-Id: <5bc4c4570810111028v7b6aed77lfdb3629e77d36229@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

---------- Forwarded message ----------
From: Leandro Sales <leandroal@gmail.com>
Date: Sat, Oct 11, 2008 at 2:28 PM
Subject: Re: Protocol not attached
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, Leandro Sales
<leandroal@gmail.com>, DCCP Mailing List <dccp@vger.kernel.org>,
Erivaldo <desadoc@gmail.com>


On Sat, Oct 11, 2008 at 4:35 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrot=
e:
>
> Leandro -
> | # lsmod
> | Module                  Size  Used by
> | dccp_tfrc_lib          17868  0
> | dccp_ipv6              14916  2
> | dccp_ipv4              14596  3 dccp_ipv6
> | dccp                   58176  2 dccp_ipv6,dccp_ipv4
> |
> | DCCP did not load the dccp_ccid2 module. Is this the problem?
> |
> are there any news regarding this issue? If there is a problem I would
> like to address it since I am submitting this patch set.

Hello Gerrit,

> > Go ahead and load it manually, to check if the problem goes away when
> > dccp_ccid2 is loaded.
> >
> > If it is, its narrowed down to the autoloading of CCID modules.
> >

After boot the following dccp modules were loaded:
Module                  Size  Used by
dccp_tfrc_lib          17868  0
dccp_ipv6              14916  2
dccp_ipv4              14596  3 dccp_ipv6
dccp                   58112  2 dccp_ipv6,dccp_ipv4

I run iperf and that error message appeared again. I then did what
Arnaldo suggested: I loaded dccp_ccid2 using modprobe, but iperf shows
the same error message. I ran iperf using strace com o 2.6.27-rc8:

strace -f -e trace=3Dnetwork iperf -s -d -l 1424 -1
Process 4374 attached
Process 4375 attached
[pid  4374] socket(PF_INET, 0x6 /* SOCK_??? */, IPPROTO_IP) =3D 3
[pid  4374] setsockopt(3, 0x10d /* SOL_?? */, 2, [1179796816], 4) =3D 0
[pid  4374] setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
[pid  4374] bind(3, {sa_family=AF_INET, sin_port=3Dhtons(5001),
sin_addr=3Dinet_addr("0.0.0.0")}, 16) =3D 0
[pid  4374] listen(3, 5)                =3D 0
[pid  4374] accept(3,  <unfinished ...>
[pid  4375] getsockopt(3, SOL_SOCKET, SO_RCVBUF, [106496], [4]) =3D 0


Regards,
Leandro.
