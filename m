From: Giuseppe Galeota <giuseppegaleota@libero.it>
Date: Wed, 28 May 2008 12:17:00 +0000
Subject: Re: Monitoring DCCP: modprobe dccp_probe
Message-Id: <483D4D3C.4060304@libero.it>
List-Id: <dccp.vger.kernel.org>
References: <483D424F.5020307@libero.it>
In-Reply-To: <483D424F.5020307@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Under General Setup I haven't found Kprobes, but I found Kprobes inside Instrumentation Support, and it is already active.
About DCCP I can see only:
Networking->Networking support->THE DCCP protocol->DCCP CCIDs configurations-->CCID2/3 debugging messages, that are already active, 
while I haven't found 'DCCP connection probing'.


Gerrit Renker ha scritto:
>> modprobe -v dccp_probe
>>
>>
>> I have follow message:
>>
>> zazze@zazze-portatile:~$ sudo modprobe -v dccp_probe
>> FATAL: Module dccp_probe not found.
>>
>>     
> This is a configuration setting. dccp_probe needs kprobes:
>  1. enable kprobes via `General setup' => Kprobes
>  2. Networking -> Networking options -> The DCCP Protocol
>     and then `DCCP connection probing' (this enables the
>     dccp_probe, the same option for TCP is under 
>     `Network testing' -> `TCP connection probing'
>  3. when loading the modules, it is best to load dccp 
>     and ccid-3 first, since dccp_probe will otherwise
>     complain about unresolved symbols.
>
> Gerrit
>
> .
>
>   

