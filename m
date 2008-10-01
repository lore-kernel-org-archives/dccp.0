From: "Leandro Sales" <leandroal@gmail.com>
Date: Wed, 01 Oct 2008 19:18:05 +0000
Subject: Re: Protocol not attached
Message-Id: <5bc4c4570810011218t50016accw17b3513fac2ef4c7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Wed, Oct 1, 2008 at 3:27 PM, Leandro Sales <leandroal@gmail.com> wrote:
> On Tue, Sep 30, 2008 at 7:11 PM, Arnaldo Carvalho de Melo
> <acme@redhat.com> wrote:
>> Em Tue, Sep 30, 2008 at 06:24:57PM -0300, Leandro Sales escreveu:
>>> On Tue, Sep 30, 2008 at 4:16 PM, Arnaldo Carvalho de Melo
>>> <acme@redhat.com> wrote:
>>> > Em Tue, Sep 30, 2008 at 03:32:17PM -0300, Leandro Sales escreveu:
>>> >> On Mon, Sep 29, 2008 at 3:37 PM, Arnaldo Carvalho de Melo
>>> >> <acme@redhat.com> wrote:
>>> >> > Em Mon, Sep 29, 2008 at 03:33:44PM -0300, Leandro Sales escreveu:
>>> >> >> Hello folks,
>>> >> >>   I'm getting this message while using 2.6.27:
>>> >> >>
>>> >> >>   Can not create DCCP socket (Protocol driver not attached)
>>> >> >
>>> >> > What is the source of such messages? VLC? What? Try strace to see =
what
>>> >> > is the syscall that fails just before this message is printed, etc.
>>> >> >
>>> >> >>   "uname -a" output:
>>> >> >>       Linux localhost 2.6.27-rc4-44301-g8269be1 #7 SMP Sun Sep 28=
 17:02:25
>>> >> >>       BRT 2008 i686 AMD Athlon(tm) 64 Processor 3000+ AuthenticAM=
D GNU/Linux
>>> >> >>
>>> >> >>   Anything wrong? I tried compile DCCP using both static and modu=
le
>>> >> >> methods and it produces the same effect.
>>> >> >
>>> >> > - Arnaldo
>>> >> >
>>> >>
>>> >> Hello Arnaldo,
>>> >>   I'm just running tests with iperf to later use gstreamer plugin th=
at
>>> >> I developed. Here it is the output provided by strace while executing
>>> >> iperf. I'm sorry for the long message. In addition, I'm providing
>>> >> support for a guy from China that wants to use my gstreamer plugin a=
nd
>>> >> he is facing similar problem, getting a permission denied message
>>> >> while using the plugin, even then he run the plugin as root.
>>> >
>>> > iperf is multithreaded, so you need to run strace with -f to trace ch=
ild
>>> > processes, also please try limiting the output to just the networking
>>> > syscalls:
>>> >
>>> > strace -f -e trace=3Dnetwork iperf
>>> >
>>> > "net namespaces" blipped in my mind, but it may well be just my brain
>>> > needing more coffee...
>>> >
>>> > - Arnaldo
>>> >
>>>
>>> Arnaldo, thank you for the reply. Please, check the strace output
>>> below. I'm not sure what it happen, although I have a thought. Any
>>> clue?
>>>
>>> Process 5849 attached (waiting for parent)
>>> Process 5849 resumed (parent 5848 ready)
>>> [pid  5849] socket(PF_NETLINK, SOCK_RAW, 0) =3D 3
>>> [pid  5849] bind(3, {sa_family=AF_NETLINK, pid=3D0, groups=00000000}, 1=
2) =3D 0
>>> [pid  5849] getsockname(3, {sa_family=AF_NETLINK, pidX48,
>>> groups=00000000}, [12]) =3D 0
>>> [pid  5849] sendto(3, "\24\0\0\0\26\0\1\3&\230\342H\0\0\0\0\0\0\0\0",
>>> 20, 0, {sa_family=AF_NETLINK, pid=3D0, groups=00000000}, 12) =3D 20
>>> [pid  5849] recvmsg(3, {msg_name(12)=3D{sa_family=AF_NETLINK, pid=3D0,
>>> groups=00000000},
>>> msg_iov(1)=3D[{"8\0\0\0\24\0\2\0&\230\342H\330\26\0\0\2\10\200\376\1\0\=
0\0\10\0\1\0\177\0\0\1"...,
>>> 4096}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 116
>>> [pid  5849] recvmsg(3, {msg_name(12)=3D{sa_family=AF_NETLINK, pid=3D0,
>>> groups=00000000},
>>> msg_iov(1)=3D[{"@\0\0\0\24\0\2\0&\230\342H\330\26\0\0\n\200\200\376\1\0=
\0\0\24\0\1\0\0\0\0\0"...,
>>> 4096}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 128
>>> [pid  5849] recvmsg(3, {msg_name(12)=3D{sa_family=AF_NETLINK, pid=3D0,
>>> groups=00000000},
>>> msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0&\230\342H\330\26\0\0\0\0\0\0\1\0\0\0\=
24\0\1\0\0\0\0\0"...,
>>> 4096}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 20
>>> [pid  5849] socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) =3D 3
>>> [pid  5849] connect(3, {sa_family=AF_INET6, sin6_port=3Dhtons(5001),
>>> inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=3D0,
>>> sin6_scope_id=3D0}, 28) =3D 0
>>> [pid  5849] getsockname(3, {sa_family=AF_INET6,
>>> sin6_port=3Dhtons(56372), inet_pton(AF_INET6, "::1", &sin6_addr),
>>> sin6_flowinfo=3D0, sin6_scope_id=3D0}, [28]) =3D 0
>>> [pid  5849] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 3
>>> [pid  5849] connect(3, {sa_family=AF_INET, sin_port=3Dhtons(5001),
>>> sin_addr=3Dinet_addr("0.0.0.0")}, 16) =3D 0
>>> [pid  5849] getsockname(3, {sa_family=AF_INET, sin_port=3Dhtons(37587),
>>> sin_addr=3Dinet_addr("127.0.0.1")}, [16]) =3D 0
>>> [pid  5849] socket(PF_INET6, 0x6 /* SOCK_??? */, 0x21 /* IPPROTO_???
>>> */) =3D -1 EUNATCH (Protocol driver not attached)
>>
>>
>> Here we gett the EUNATACH when trying SOCK_DCCP (6), IPPROTO_DCCP (33),
>> but I couldn't find any EUNATACH return in the sock_create path, do you
>> have selinux running?
>>
>> It tries several times PF_INET6 then falls back to PF_INET. Is this
>> using glibc? dietlibc? ARM? lsmod output can also help.
>>
>> - Arnaldo
>>
>
> Hello Arnaldo,
>
> kernel version: 2.6.27-rc4 (from gerrit git three)
>
> sys-libs/glibc version: 2.6.1
>
> No selinux running.
>
> In addition, this problem is occurring in both the desktop and on nokia n=
800.
>
> Thank you,
> Leandro.
>

Just completing the information. Using 2.6.26 on arm worked.

Regards,
Leandro.
