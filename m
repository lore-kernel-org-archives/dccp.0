From: "Patrick Andrieux" <patrick.andrieux@gmail.com>
Date: Tue, 05 Jun 2007 15:32:39 +0000
Subject: Re: segfault : modprobe dccp_probe
Message-Id: <fca78b970706050832n742d696cxf501d441262edcc0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <fca78b970706050607p557cc70u981116223fc72376@mail.gmail.com>
In-Reply-To: <fca78b970706050607p557cc70u981116223fc72376@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

No, I only tried on my arch, not a laptop but a desktop, intel P4.

And you are right, I've the same problem with `modprobe -v tcp_probe'.
Do you think the problem could come from my 2.6.22 kernel config ?
Because it works on 2.6.20-12 kernel with Ian's patches...

As I said to Arnaldo, I'll try with Ian's patches.

Patrick.


On 05/06/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  EIP: [<c0320687>]
> |  arch_arm_kprobe+0x6/0xb SS:ESP 0068:e5f74ea0
> |  Jun 5 12:26:55 dccpServer kernel: [ 1027.751806] BUG: sleeping
> |  function called from invalid context at kernel/rwsem.c:20
> Have you tried to do the same on a different architecture?
>
> Apparently kprobes are not supported equally well on all architectures,
> the configuration file looks like a laptop with a Pentium-M, so if
> you try `modprobe -v dccp_probe' on another computer, do you still
> get the same result.
>
> If this is due to a problem with kprobes, then `modprobe -v tcp_probe'
> will likely also give segfault.
>
> Gerrit
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
