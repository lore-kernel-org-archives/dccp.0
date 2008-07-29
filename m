From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 06:16:35 +0000
Subject: Re: DCCP Conformance Test Suite
Message-Id: <20080729061635.GB4555@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <488D3270.1020704@cn.fujitsu.com>
In-Reply-To: <488D3270.1020704@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> Last, there is ongoing work to add ECN support. For ECN it would be
>> helpful to look at the behaviour, since ECN router support seems quite
>> young
>
> Do you mean send packet with ECN in the ip header? I'll have a look to  
> the ECN RFC, and check if it can.
>
ECN is work in progress and will take some time since it requires
changes to CCID-3 and other parts.

For the moment it is probably best to work on the bugs in the existing
code (apparently there are still 22 "fail" cases).

Gerrit
