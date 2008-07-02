From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 02 Jul 2008 12:19:43 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <486B725F.50608@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker pisze:
> [limited the lists to dccp@vger since this is DCCP-specific and not a patch]
> 
>> Ok, so now we know how to store information about parameters in kernel
>> structures. What remains to be discussed is how to pass that information
>> to userspace.
>>
> To me the less spectacular way of "just document it" still seems the best
> solution. 
Documentation doesn't suffice because parameters may change from version 
to version.

> The other suggestion (below) is to divide this requirement
> and, if really needed, use an API library which provides such mechanisms.
> 
It may be that I miss something but currently I don't see how such a 
function could be implemented in a clean way. Could you please write a 
sketch of such an implementation? The function's signature could be:
	bool paramsSupported(int sockfd, int params);
and we could call it like this:
	int sockfd=socket(...);
	setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_PRIO);
	paramsSupported(sockfd, DCCP_SCM_PRIORITY); //should return true
	paramsSupported(sockfd, DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT); //should 
return false
-- 
Regards,
Tomasz Grobelny
