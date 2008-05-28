From: "Leandro Sales" <leandroal@gmail.com>
Date: Wed, 28 May 2008 12:50:10 +0000
Subject: Re: Monitoring DCCP: modprobe dccp_probe
Message-Id: <5bc4c4570805280550g684123a1y53d92741460d61b5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <483D424F.5020307@libero.it>
In-Reply-To: <483D424F.5020307@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, May 28, 2008 at 9:38 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Giuseppe Galeota:
>> Under General Setup I haven't found Kprobes, but I found Kprobes inside Instrumentation Support, and it is already active.
>> About DCCP I can see only:
>> Networking->Networking support->THE DCCP protocol->DCCP CCIDs
>> configurations-->CCID2/3 debugging messages, that are already active,
>> while I haven't found 'DCCP connection probing'.
>>
> This means that the dependency for dccp_probe is not satisfied.
> The only other dependency of dccp_probe is CONFIG_PROC_FS, but this is
> not normally off. Maybe if you are using non-x86 hardware there is a
> problem with kprobes?

Yes, this should be the point. For instance, I'm maintaining DCCP
source code for maemo platform (ARM) that runs with 2.6.21 kernel
version and they do not provide KProbes and for this case I had to
make some internal changes to avoid dccp kprobes. As Gerrit said,
check if kprobe dependencies are selected.

>
> Alternatively, if you do a
>
>        grep CONFIG_NET_DCCPPROBE .config
>
> you should be getting a CONFIG_NET_DCCPPROBE=m (`y' also apparently works).
> If it is not set then check if PROC_FS is on, if not then the source is
> somewhere else.

This is a good alternative.

> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Leandro Melo de Sales
Pervasive and Embedded Computing Laboratory
Computer Science MSc.
BRisa and E-Phone Projects Manager
Network Admin @ http://embedded.ufcg.edu.br/indexen.html
+55 83 3310-1404 (extension 208)

http://www.leandrosales.com/
