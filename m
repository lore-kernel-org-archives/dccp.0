From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 20 Aug 2007 02:57:50 +0000
Subject: Re: Kernel version of Arnaldos Net Git tree
Message-Id: <5640c7e00708191957q6929d573mab853908a521f9e5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
In-Reply-To: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/20/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> In both tree, Gerrit tree and Arnaldo tree I'm in trouble. I compiled
> the kernel and on the boot I'm getting the following messages and
> after this the pc stop to work:
>
> Testing NMI watchdog ... <7>APIC error on CPU0: 40(40)
> CPU#0: NMI appears to be stuck (0->0)!
> CPU#1: NMI appears to be stuck (0->0)!
> Using IPI No-Shortcut mode
> drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
>
> Any clue to solve this?
>
> Thanks,
> Leandro.
>

Try Linus' tree and see if there is the same issue. From memory this
is a clock issue that has been solved very recently.

If it hasn't been solved then report to the lkml list. If it has been
solved you can wait until the trees are rebased or you can copy the
patches yourself over to a copy of Linus' tree.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
