From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Mon, 20 Aug 2007 02:54:10 +0000
Subject: Re: Kernel version of Arnaldos Net Git tree
Message-Id: <5bc4c4570708191954w68bd4d42j5c56d767ede1a5d8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
In-Reply-To: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In both tree, Gerrit tree and Arnaldo tree I'm in trouble. I compiled
the kernel and on the boot I'm getting the following messages and
after this the pc stop to work:

Testing NMI watchdog ... <7>APIC error on CPU0: 40(40)
CPU#0: NMI appears to be stuck (0->0)!
CPU#1: NMI appears to be stuck (0->0)!
Using IPI No-Shortcut mode
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)

Any clue to solve this?

Thanks,
Leandro.

2007/8/19, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> On 8/20/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> > Hi Arnaldo,
> >      today I clone your git kernel and although it is shown 2.6.24,
> > when I run make menuconfig it is shown 2.6.23-rc2. Is there something
> > missing in what I did when I clone the tree?
> >
> > Leandro.
> >
> Leandro,
>
> This is aimed at the 2.6.24 release, rather than being based on 2.6.24.
>
> It is based on 2.6.23-rc2 as that was the latest at the time when
> Arnaldo was working on his tree. 2.6.23 has not yet been released.
>
> Ian
> --
> Web1: http://wand.net.nz/~iam4/
> Web2: http://www.jandi.co.nz
> Blog: http://iansblog.jandi.co.nz
>


-- 
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager & Network Administrator
http://embedded.ufcg.edu.br/
+55 083 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
