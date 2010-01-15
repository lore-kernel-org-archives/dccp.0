From: David Miller <davem@davemloft.net>
Date: Fri, 15 Jan 2010 09:41:10 +0000
Subject: Re: [PATCH] dccp_probe: Fix module load dependencies between dccp
Message-Id: <20100115.014110.33561920.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20100114201517.GA32352@hmsreliant.think-freely.org>
In-Reply-To: <20100114201517.GA32352@hmsreliant.think-freely.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 14 Jan 2010 18:17:43 -0200

> Em Thu, Jan 14, 2010 at 03:15:17PM -0500, Neil Horman escreveu:
>> Hey-
>> 	This was just recently reported to me.  When built as modules,
>> the dccp_probe module has a silent dependency on the dccp module.  This stems
>> from the fact that the module_init routine of dccp_probe registers a jprobe on
>> the dccp_sendmsg symbol.  Since the symbol is only referenced as a text string
>> (the .symbol_name field in the jprobe struct) rather than the address of the
>> symbol itself, depmod never picks this dependency up, and so if you load the
>> dccp_probe module without the dccp module loaded, the register_jprobe call fails
>> with an -EINVAL, and the whole module load fails.
>> 
>> 	The fix is pretty easy, we can just wrap the register_jprobe call in a
>> try_then_request_module call, which forces the dependency to get satisfied prior
>> to the probe registration.
>> 
>> 	I've verified that this fixes the problem myself.
>> 
>> Regards
>> Neil
>> 
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> That is ok with me, thanks!
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.

Neil, always CC: netdev on networking patches, thanks.
