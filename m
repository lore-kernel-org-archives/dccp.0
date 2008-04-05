From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 05 Apr 2008 10:12:08 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <47F75078.3070205@netfilter.org>
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Jan Engelhardt wrote:
> 
> On Friday 2008-04-04 17:41, Patrick McHardy wrote:
>> These two patches contain my old conntrack/NAT helper for DCCP,
>> updated to net-2.6.26.git and the missing parts (almost entirely)
>> added.
>>
>> They both depend on some other netfilter patches, I've attached
>> them only hoping for some review :) A git tree which contains
>> the full set of patches is (once upload finishes) located at:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.26.git
> 
> Speaking of git... I noticed people.netfilter.org has a git-daemon,
> so that would be fine for iptables, no?

No, that's for a different purpose. We are setting up another git
repository in Vishnu that will keep soon iptables.

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
