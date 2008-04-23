From: Patrick McHardy <kaber@trash.net>
Date: Wed, 23 Apr 2008 00:03:43 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version
Message-Id: <480E7CDF.2060301@trash.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

David Miller wrote:
> From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
> Date: Tue, 22 Apr 2008 22:45:53 +0200
> 
>> Maybe I wasn't clear enough with my question. I understand that
>> these two memsets would have to be readded. But my question is: did
>> you identify any bugs that were caused by junk in skb->cb before
>> applying your patch? If so, do you have any test cases? It could
>> help to check code for correctness if one day more space in skb->cb
>> will be needed (which of course doesn't have to be in the nearest
>> future).
> 
> I think Patrick noticed it because it broke netfilter.
> 

Exactly, at least one path to the IP stack didn't clear
the CB (I don't recall the exact function, sorry). The
same is true for IPv6.

The testcase was transfering data over NATed DCCP connections,
some packets had garbage in IPCB(skb)->flags, which caused
IP to skip the POST_ROUTING hook, breaking NAT and conntrack.

