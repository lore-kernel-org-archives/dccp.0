From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Jun 2007 13:51:39 +0000
Subject: Re: segfault : modprobe dccp_probe
Message-Id: <200706051451.39875@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <fca78b970706050607p557cc70u981116223fc72376@mail.gmail.com>
In-Reply-To: <fca78b970706050607p557cc70u981116223fc72376@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  EIP: [<c0320687>]
|  arch_arm_kprobe+0x6/0xb SS:ESP 0068:e5f74ea0
|  Jun =A05 12:26:55 dccpServer kernel: [ 1027.751806] BUG: sleeping
|  function called from invalid context at kernel/rwsem.c:20
Have you tried to do the same on a different architecture?

Apparently kprobes are not supported equally well on all architectures,=20
the configuration file looks like a laptop with a Pentium-M, so if
you try `modprobe -v dccp_probe' on another computer, do you still
get the same result.

If this is due to a problem with kprobes, then `modprobe -v tcp_probe'
will likely also give segfault.

Gerrit
