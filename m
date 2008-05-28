From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 28 May 2008 14:07:57 +0000
Subject: Re: Monitoring DCCP: modprobe dccp_probe
Message-Id: <20080528140757.GA16145@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <483D424F.5020307@libero.it>
In-Reply-To: <483D424F.5020307@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Giuseppe Galeota:
> I have enclosed my file .config of the 2.6.24 kernel that I'm using.
> I read:
>
> CONFIG_PROC_FS=y
>
> but I haven't found CONFIG_NET_DCCPPROBE.
>
Weird, since it allowed to set CONFIG_NET_TCPPROBE=m. Seems to be
Athlon/Duron K7.

To rule out that the fault is due to patching, can you try if you can get
CONFIG_NET_DCCPPROBE=m on an unpatched 2.6.24 kernel?

Or re-run (make clean; make oldconfig)?
