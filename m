From: Giuseppe Galeota <giuseppegaleota@libero.it>
Date: Thu, 29 May 2008 11:54:22 +0000
Subject: Re: Monitoring DCCP: modprobe dccp_probe
Message-Id: <483E996E.7090907@libero.it>
List-Id: <dccp.vger.kernel.org>
References: <483D424F.5020307@libero.it>
In-Reply-To: <483D424F.5020307@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,
I have resolved.
The problem was that the "kernel debugging" in the .config file wasn't 
active.
Now, I can see 'DCCP connection probing' inside Networking-->Networking 
options -> The DCCP Protocol.

Thank you,
Giuseppe




Gerrit Renker ha scritto:
> Quoting Giuseppe Galeota:
>   
>> Under General Setup I haven't found Kprobes, but I found Kprobes inside Instrumentation Support, and it is already active.
>> About DCCP I can see only:
>> Networking->Networking support->THE DCCP protocol->DCCP CCIDs 
>> configurations-->CCID2/3 debugging messages, that are already active,  
>> while I haven't found 'DCCP connection probing'.
>>
>>     
> This means that the dependency for dccp_probe is not satisfied.
> The only other dependency of dccp_probe is CONFIG_PROC_FS, but this is
> not normally off. Maybe if you are using non-x86 hardware there is a
> problem with kprobes?
>     
> Alternatively, if you do a 
>
> 	grep CONFIG_NET_DCCPPROBE .config
>
> you should be getting a	CONFIG_NET_DCCPPROBE=m (`y' also apparently works).
> If it is not set then check if PROC_FS is on, if not then the source is 
> somewhere else.
> .
>
>   

