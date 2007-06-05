From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 05 Jun 2007 15:42:19 +0000
Subject: Re: segfault : modprobe dccp_probe
Message-Id: <39e6f6c70706050842x3395e84fv4a592e9016f67552@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <fca78b970706050607p557cc70u981116223fc72376@mail.gmail.com>
In-Reply-To: <fca78b970706050607p557cc70u981116223fc72376@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/5/07, Patrick Andrieux <patrick.andrieux@gmail.com> wrote:
> No, I only tried on my arch, not a laptop but a desktop, intel P4.
>
> And you are right, I've the same problem with `modprobe -v tcp_probe'.
> Do you think the problem could come from my 2.6.22 kernel config ?
> Because it works on 2.6.20-12 kernel with Ian's patches...
>
> As I said to Arnaldo, I'll try with Ian's patches.

You'll probably get the same results :)

This extra information that the problem happens as well with tcp_probe
seems to strongly point to a problem with kprobes, perhaps something
done after 2.6.20 that changes kprobes ABI and that was not reflected
even on the in-kernel kprobes/jprobes users.

- Arnaldo
